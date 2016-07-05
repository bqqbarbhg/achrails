class VideosController < ApplicationController

  def index
    authenticate_user!

    respond_to do |format|
      format.json do

        own_video_columns = current_user.authored_videos.pluck(:id, :uuid, :revision_num)
        group_video_columns = current_user.videos.pluck(:id, :uuid, :revision_num)

        all_video_columns = (own_video_columns + group_video_columns).uniq { |c| c[0] }
        @all_videos = all_video_columns.map { |c| { id: c[0].to_s, uuid: c[1], revision: c[2] } }

        render json: { videos: @all_videos }
      end
      format.html do
        own_videos = current_user.authored_videos.order(created_at: :desc)
        group_videos = current_user.videos.order(created_at: :desc)

        @videos = (own_videos + group_videos).uniq { |c| c.id }

        render
      end
    end
  end

  def own
    authenticate_user!

    @videos = current_user.authored_videos.order(created_at: :desc)
    @upload_token = current_user.create_upload_token

    render
  end

  def show
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    if (params[:is_view] || request.format.html?) && current_user.present?
      time = Time.now.to_i / (60 * 60) # hours

      recent_views = current_user.recent_views || { }

      # Remove views that are older than 24h
      limit = time - 24
      new_recent_views = recent_views.select { |k,v| v >= limit }

      # If this video is still in the hash it was viewed in the last 24h
      if new_recent_views[@video.uuid].nil?

        # Count as a new view
        new_recent_views[@video.uuid] = time
        @video.increment!(:views)

        log_event(:view_video, @video)

      end

      if new_recent_views != recent_views
        current_user.update(recent_views: new_recent_views)
      end
    end

    if params[:newer_than_rev].present? and @video.revision_num == params[:newer_than_rev].to_i
      render nothing: true, status: :not_modified
      return
    end

    @manifest = if params[:rev].present?
      @video.manifest_revision(params[:rev].to_i)
    else
      @video.read_manifest
    end

    # Force reload
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"


    respond_to do |format|
      format.html do
        # HACK: Force reauthentication since the page does XHR
        sss.force_authenticate() if current_user && sss
        render
      end
      format.json { render json: @manifest }
    end

    # Call webhook
    @video.groups.each do |group|
      group.video_view_call_webhook(@video, current_user)
    end

  end

  def edit
    @video = Video.find_by_uuid(params[:id])
    authorize @video
    @manifest = @video.read_manifest
    render
  end

  def properties
    @video = Video.find_by_uuid(params[:id])
    manifest = @video.read_manifest.clone

    manifest["title"] = params[:title]
    manifest["genre"] = params[:genre]

    update_video_with_manifest(@video, manifest)

    redirect_to action: :show, id: @video.uuid
  end

  def player
    # TODO: Create secure token?
    @manifest = Video.find_by_uuid(params[:id]).read_manifest

    # Anonymize the manifest (for now)
    #
    # This is done since there is no user visible info about the authors or
    # location in the player, but the source still contains the manifest, so
    # users could embed the player with a false sense of privacy while the
    # source code leaks info.
    # TODO: If some of this data is made visible then don't remove that piece
    #       of data here.

    # NOTE: DO NOT SAVE THE MANIFEST!!!
    # These are temporary modifications only
    @manifest["author"] = nil
    @manifest["location"] = nil
    for annotation in @manifest["annotations"]
      annotation["author"] = nil
    end

    # Allow to embed in an iframe
    response.headers.delete "X-Frame-Options"

    render layout: false
  end

  def create
    authenticate_user!

    @video = Video.from_manifest(request.body.read, current_user)
    sss.create_video(@video) if sss
    respond_to do |format|
      format.html { redirect_to action: :show, id: @video.uuid }
      format.json { render json: { url: video_url(@video) } }
    end
  end

  def update
    manifest = JSON.parse(request.body.read)
    @video = Video.find_by_uuid(params[:id])

    status = update_video_with_manifest(@video, manifest)

    render json: @video.read_manifest, status: status
  end

  def update_video_with_manifest(video, manifest)
    Util.normalize_manifest!(manifest)

    is_new = false

    if @video
      # todo: rethink how to safely update only the mutable fields of the manifest.
      # merge_manifest is fine, but currently its results are not used and if it would use only 
      # the mutable portion of the new manifest
      authorize @video, :update?
      ignore = ["revision", "uploadedAt", "lastModified", "editedBy", "rotation", "deleteUri"] 
      # temporarily added deleteUri and rotation, if the rejection of some annotation updates was
      # caused by them being or being missing in Ach so! sent manifests and reverse in achrails 
      if @video.read_manifest.except(*ignore) == manifest.except(*ignore)
        return :ok
      end

      # Only allow the following keys to be mutable
      mutable_keys = ["title", "genre", "tag", "formatVersion", "annotations"]

      mutable_manifest = manifest.clone.extract!(*mutable_keys)
      previous_manifest = @video.manifest_json.clone
      manifest = previous_manifest.merge(mutable_manifest)

      parent_rev = manifest["revision"]
      if parent_rev != @video.revision_num
        parent_manifest = @video.manifest_revision(parent_rev)
        merge = Util.merge_manifests(manifest, @video.manifest_json, parent_manifest)
        # (jukka) it seems that merge[:manifest] is not used at all. is this on purpose? 
        lost_data = merge[:lost_data]
      end
    else
      authenticate_user!
      @video = Video.new(revision_num: 0, author: current_user)
      is_new = true
    end

    manifest["uploadedAt"] = Time.now.utc.iso8601
    manifest["editedBy"] = current_user.name

    @video.import_manifest_data(manifest)

    sss.create_video(@video) if sss

    @video.update_manifest(manifest)

    if is_new
      log_event(:upload_video, @video)
    else

      @video.groups.each do |group|
        group.video_edit_call_webhook(@video, current_user)
      end

      log_event(:edit_video, @video)
    end

    return :created
  end

  def upload
    authenticate_user!

    @video = Video.new(revision_num: 0, author: current_user)

    manifest = JSON.parse(params[:manifest].read)
    Util.normalize_manifest!(manifest)

    manifest["uploadedAt"] = Time.now.utc.iso8601

    @video.update_manifest(manifest)
    sss.create_video(@video) if sss

    redirect_to action: :show, id: @video.uuid
  end

  def upload_callback

    time = Time.now.utc.iso8601

    manifest = {
      id: SecureRandom.uuid,
      date: time,
      uploadedAt: time,
      revision: 0,
      title: params[:title] || Time.now.to_formatted_s(:db),
      genre: "good_work",
      videoUri: params[:video_url],
      thumbUri: params[:thumb_url],
      deleteUri: params[:delete_url],
      author: current_user.manifest_json,
      annotations: [],
      rotation: 0,
      editedBy: current_user.name,
      formatVersion: 1,
    }
    manifest.stringify_keys!

    @video = Video.new(revision_num: 0, author: current_user)

    Util.normalize_manifest!(manifest)

    @video.update_manifest(manifest)
    sss.create_video(@video) if sss

    redirect_to action: :edit, id: @video.uuid
  end

  def destroy
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    log_event(:delete_video, @video)

    # Delete the video data
    manifest = @video.read_manifest
    deleteUrl = manifest["deleteUri"]
    if deleteUrl.present?
      response = Faraday.delete(deleteUrl) do |req|
        req.headers['Authorization'] = "Bearer #{current_user.bearer_token}"
      end
      Rails.logger.debug "DELETE #{deleteUrl} -> #{response.status}"
    end

    # SSS_Support(delete video)
    @video.destroy

    respond_to do |format|
      format.html { redirect_to action: :index }
      format.json { render nothing: true, status: :no_content }
    end
  end

  def find
    video_url = Util.normalize_url(params[:video])

    @video = Video.where(video_url: video_url).first

    if @video
      render json: @video.read_manifest
    else
      render nothing: true, status: :not_found
    end
  end

  def search
    # TODO: Pagination
    # NOTE: This is slow!

    @query = params[:q]
    videos = Video.search(@query)

    videos = videos.select { |video| policy(video).show? }

    @manifests = videos.map(&:read_manifest)
    respond_to do |format|
      format.html { render }
      format.json { render json: { videos: @manifests }}
    end
  end

  def revisions
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    @revisions = @video.all_revisions

    respond_to do |format|
      format.html { render }
      format.json { render json: @revisions }
    end
  end

  def revert
    revision = params[:revision].to_i

    @video = Video.find_by_uuid(params[:id])
    unless @video
      render nothing: true, status: :not_found and return
    end

    authorize @video

    manifest = @video.manifest_revision(revision)
    manifest["uploadedAt"] = Time.now.utc.iso8601
    @video.update_manifest(manifest)

    sss.create_video(@video) if sss

    redirect_to action: :show, id: @video.uuid
  end

end

