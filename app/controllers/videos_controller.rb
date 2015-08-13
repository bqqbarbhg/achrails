
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
        headers['ETag'] = '"' + @video.id.to_s + ':' + @video.revision.to_s + '"'
        render json: @video.read_manifest
      end
    end
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
      # Creating videos in SSS with the same UUID results in overwriting the old one.
      @video = Video.from_manifest(request.body.read, current_user)
      sss.create_video(@video)
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

    redirect_to action: :index
  end

protected
  def video_params(manifest)
    json = JSON.parse(manifest)
    { title: json["title"],
      uuid: json["id"],
      author: current_user,
      manifest_json: json }
  end
end

