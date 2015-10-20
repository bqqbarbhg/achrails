
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

        own_video_columns = current_user.authored_videos.pluck(:id, :uuid, :updated_at)
        group_video_columns = current_user.videos.pluck(:id, :uuid, :updated_at)

        all_video_columns = (own_video_columns + group_video_columns).uniq { |c| c[0] }
        @all_videos = all_video_columns.map { |c| { id: c[0].to_s, uuid: c[1], last_modified: c[2].httpdate } }

        render json: { videos: @all_videos }
      end
    end
  end

  def show
    @video = Video.find_by_uuid(params[:id])
    authorize @video

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
    # TODO: Merging

    @old_video = Video.find_by_uuid(params[:id])
    params = video_params(request.body.read)

    if @old_video
      authorize @old_video
      @old_video.update(params)
      @new_video = @old_video
    else
      @new_video = Video.create!(params)
    end
    sss.create_video(@new_video) if sss

    @new_video.history = @new_video.history.unshift(params[:manifest_json])

    status = @old_video ? :ok : :created
    render nothing: true, status: status
  end

  def upload
    @video = Video.from_manifest(params[:manifest].read, current_user)
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

protected
  def video_params(manifest)
    # @CutPaste video params
    json = JSON.parse(manifest)
    { title: json["title"],
      uuid: json["id"],
      author: current_user,
      manifest_json: json,
      searchable: Util.manifest_to_searchable(json),
      video_url: Util.normalize_url(json["videoUri"]) }
  end
end

