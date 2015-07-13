
class VideosController < ApplicationController

  def index

    # TODO: This returns different data sets now for html and json.
    # TODO: Think about routes harder.

    respond_to do |format|
      format.html do
        @videos = current_user.authored_videos
        render
      end
      format.json do

        own_video_columns = current_user.authored_videos.pluck(:id, :uuid, :manifest_updated_at)
        group_video_columns = current_user.videos.pluck(:id, :uuid, :manifest_updated_at)

        all_video_columns = (own_video_columns + group_video_columns).uniq { |c| c[0] }
        all_videos = all_video_columns.map { |c| { id: c[0].to_s, uuid: c[1], last_modified: c[2].httpdate } }

        render json: { videos: all_videos }
      end
    end
  end

  def show
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    respond_to do |format|
      format.html { render }
      format.json do
        headers['ETag'] = '"' + @video.id.to_s + ':' + @video.revision.to_s + '"'
        render json: @video.read_manifest
      end
    end
  end

  def create
    @video = create_video(request.body.read)
    redirect_to action: :show, id: @video.uuid
  end

  def upload
    @video = create_video(params[:manifest].read)
    redirect_to action: :show, id: @video.uuid
  end

  def create_video(json)
    json = JSON.parse(json)
    Video.create! title: json["title"],
                  uuid: json["id"],
                  author: current_user,
                  manifest: StringIO.new(JSON.generate json)
  end

  def destroy
    @video = Video.find_by_uuid(params[:id])
    authorize @video

    @video.destroy

    redirect_to :back
  end

protected
  def video_params
    p = params.require(:video).accept(:title)
    p[:author] = current_user
  end
end

