
class VideosController < ApplicationController

  def index

    # TODO: This returns different data sets now for html and json.
    # TODO: Think about routes harder.
    # TODO: Logged out view

    authenticate_user!

    respond_to do |format|
      format.html do
        if sss
          @videos = sss.videos
        else
          @videos = current_user.authored_videos
        end
        render
      end
      format.json do

        if sss
          own_videos = sss.videos.select { |video| video.author?(current_user) }
          group_videos = sss.groups_for(current_user).map { |group| group.videos }.reduce(:+) || []
          videos = (own_videos + group_videos).uniq
          @all_videos = videos.map do |video|
            { id: video.uuid, uuid: video.uuid, last_modified: video.last_modified.httpdate }
          end
        else
          own_video_columns = current_user.authored_videos.pluck(:id, :uuid, :updated_at)
          group_video_columns = current_user.videos.pluck(:id, :uuid, :updated_at)

          all_video_columns = (own_video_columns + group_video_columns).uniq { |c| c[0] }
          @all_videos = all_video_columns.map { |c| { id: c[0].to_s, uuid: c[1], last_modified: c[2].httpdate } }
        end

        render json: { videos: @all_videos }
      end
    end
  end

  def show
    if sss
      @video = sss.video(params[:id])
    else
      @video = Video.find_by_uuid(params[:id])
      authorize @video
    end

    respond_to do |format|
      format.html { render }
      format.json do
        headers['ETag'] = '"' + @video.uuid.to_s + ':' + @video.revision.to_s + '"'
        render json: @video.read_manifest
      end
    end
  end

  def player
    # TODO: Create secure token?
    if sss?
      @manifest = VideoManifest.where(uuid: params[:id]).first.read_manifest
    else
      @manifest = Video.find_by_uuid(params[:id]).read_manifest
    end

    # Anonymize the manifest (for now)
    #
    # This is done since there is no user visible info about the authors or
    # location in the player, but the source still contains the manifest, so
    # users could embed the player with a false sense of privacy while the
    # source code leaks info.
    # TODO: If some of this data is made visible then don't remove that piece
    #       of data here.
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
    if sss
      sss.create_video(@video)
    end
    respond_to do |format|
      format.html { redirect_to action: :show, id: @video.uuid }
      format.json { render json: { url: video_url(@video) } }
    end
  end

  def update
    if sss
      # @Hack: Set old_video as boolean depending if it exists already
      @old_video = VideoManifest.exists?(uuid: params[:id])
      # Creating videos in SSS with the same UUID results in overwriting the old one.
      @new_video = Video.from_manifest(request.body.read, current_user)
      sss.create_video(@new_video)
    else
      @old_video = Video.find_by_uuid(params[:id])
      params = video_params(request.body.read)

      if @old_video
        params[:revision] = @old_video.revision + 1
        @old_video.update(params)
        @new_video = @old_video
      else
        @new_video = Video.create(params)
      end
    end

    headers['ETag'] = '"' + @new_video.uuid.to_s + ':' + @new_video.revision.to_s + '"'
    status = @old_video ? :ok : :created
    render nothing: true, status: status
  end

  def upload
    @video = Video.from_manifest(params[:manifest].read, current_user)
    if sss
      sss.create_video(@video)
    end
    redirect_to action: :show, id: @video.uuid
  end

  def destroy
    # SSS_Support(delete video)
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    @video.destroy

    respond_to do |format|
      format.html { redirect_to action: :index }
      format.json { render nothing: true, status: :no_content }
    end
  end

  def find
    # TODO: Authorization?
    video_url = Util.normalize_url(params[:video])

    if sss?
      @video = VideoManifest.where(video_url: video_url).first
    else
      @video = Video.where(video_url: video_url).first
    end

    if @video
      render json: @video.read_manifest
    else
      render nothing: true, status: :not_found
    end
  end

  def search
    @query = params[:q]
    if sss
      @manifests = VideoManifests.search(@query).map(&:read_manifest)
    else
      @manifests = Video.search(@query).map(&:read_manifest)
    end

    render
  end

protected
  def video_params(manifest)
    json = JSON.parse(manifest)
    { title: json["title"],
      uuid: json["id"],
      author: current_user,
      manifest_json: json,
      searchable: Util.manifest_to_searchable(json),
      video_url: Util.normalize_url(json["videoUri"]) }
  end
end

