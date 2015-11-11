class VideosController < ApplicationController

  def index

    # TODO: This returns different data sets now for html and json.
    # TODO: Think about routes harder.
    # TODO: Logged out view

    authenticate_user!

    respond_to do |format|
      format.html do
        @videos = current_user.authored_videos
        render
      end
      format.json do

        own_video_columns = current_user.authored_videos.pluck(:id, :uuid, :revision_num)
        group_video_columns = current_user.videos.pluck(:id, :uuid, :revision_num)

        all_video_columns = (own_video_columns + group_video_columns).uniq { |c| c[0] }
        @all_videos = all_video_columns.map { |c| { id: c[0].to_s, uuid: c[1], revision: c[2] } }

        render json: { videos: @all_videos }
      end
    end
  end

  def show
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    @manifest = if params[:rev].present?
      @video.manifest_revision(params[:rev].to_i)
    else
      @video.read_manifest
    end

    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"

    respond_to do |format|
      format.html do
        # HACK: Force reauthentication since the page does XHR
        sss.force_authenticate() if sss
        render
      end
      format.json { render json: @manifest }
    end
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
    # NOTE: NO NOT SAVE!!!
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
    @video = Video.from_manifest(request.body.read, current_user)
    sss.create_video(@video) if sss
    respond_to do |format|
      format.html { redirect_to action: :show, id: @video.uuid }
      format.json { render json: { url: video_url(@video) } }
    end
  end

  def update

    manifest = JSON.parse(request.body.read)
    Util.normalize_manifest!(manifest)

    @video = Video.find_by_uuid(params[:id])
    if @video
      authorize @video
      ignore = ["revision", "uploadedAt", "lastModified"]
      if @video.read_manifest.except(*ignore) == manifest.except(*ignore)
        render json: @video.read_manifest, status: :ok
        return
      end

      parent_rev = manifest["revision"]
      if parent_rev != @video.revision_num
        parent_manifest = @video.manifest_revision(parent_rev)
        merge = Util.merge_manifests(manifest, @video.manifest_json, parent_manifest)
        manifest = merge[:manifest]
        lost_data = merge[:lost_data]
      end

    else
      # TODO: Authorization
      @video = Video.new(revision_num: 0, author: current_user)
    end

    manifest["uploadedAt"] = Time.now.utc.iso8601

    @video.import_manifest_data(manifest)

    sss.create_video(@video) if sss

    @video.update_manifest(manifest)

    status = @video.revision_num > 1 ? :ok : :created

    render json: @video.manifest_json, status: status
  end

  def upload
    @video = Video.new(revision_num: 0, author: current_user)

    manifest = JSON.parse(params[:manifest].read)
    Util.normalize_manifest!(manifest)

    manifest["uploadedAt"] = Time.now.utc.iso8601

    @video.update_manifest(manifest)
    sss.create_video(@video) if sss

    redirect_to action: :show, id: @video.uuid
  end

  def destroy
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    # SSS_Support(delete video)
    @video.destroy

    respond_to do |format|
      format.html { redirect_to action: :index }
      format.json { render nothing: true, status: :no_content }
    end
  end

  def find
    # TODO: Authorization?
    video_url = Util.normalize_url(params[:video])

    @video = Video.where(video_url: video_url).first

    if @video
      render json: @video.read_manifest
    else
      render nothing: true, status: :not_found
    end
  end

  def search
    @query = params[:q]
    @manifests = Video.search(@query).map(&:read_manifest)

    render
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

    if @video
      authorize @video
    else
      # TODO: Authorization
      Video.new(revision_num: 0, author: current_user)
    end

    manifest = @video.manifest_revision(revision)
    manifest["uploadedAt"] = Time.now.utc.iso8601
    @video.update_manifest(manifest)

    sss.create_video(@video) if sss

    redirect_to action: :show, id: @video.uuid
  end

end

