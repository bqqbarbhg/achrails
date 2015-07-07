
class VideosController < ApplicationController

  def index
    @videos = current_user.authored_videos

    render
  end

  def show
    @video = Video.find(params[:id])
    # TODO: Authorize

    render
  end

  def upload
    json = JSON.parse(params[:manifest].read)
    @video = Video.create!(
      title: json["title"],
      author: current_user)

    redirect_to action: :show, id: @video.id
  end

  def destroy
    @video = Video.find(params[:id])
    # TODO: Authorize

    @video.destroy

    redirect_to :back
  end

protected
  def video_params
    p = params.require(:video).accept(:title)
    p[:author] = current_user
  end
end

