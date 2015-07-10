
class VideosController < ApplicationController

  def index
    @videos = current_user.authored_videos

    render
  end

  def show
    @video = Video.find(params[:id])
    authorize @video

    respond_to do |format|
      format.html { render }
      format.json { render json: @video.read_manifest }
    end
  end

  def create
    @video = create_video(request.body.read)
    redirect_to action: :show, id: @video.id
  end

  def upload
    @video = create_video(params[:manifest].read)
    redirect_to action: :show, id: @video.id
  end

  def create_video(json)
    json = JSON.parse(json)
    Video.create! title: json["title"],
                  author: current_user,
                  manifest: StringIO.new(JSON.generate json)
  end

  def destroy
    @video = Video.find(params[:id])
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

