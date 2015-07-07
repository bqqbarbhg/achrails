
class VideosController < ApplicationController

  def index
    @videos = current_user.authored_videos

    render
  end

  def show
    @video = Video.find(params[:id])
    authorize @video

    render
  end

  def upload
    json = JSON.parse(params[:manifest].read)
    @video = Video.create!(
      title: json["title"],
      author: current_user)

    redirect_to action: :show, id: @video.id
  end

  def update
    # TODO: Share logic with create

    @video = Video.find(params[:id])
    authorize @video

    shares = params[:share]
    
    @video.groups.clear

    # TODO: Make this atomic
    # TODO: Check if this is possible to do with only id:s
    if shares
      for key, val in shares
        @video.groups << Group.find(key.to_i)
      end
    end

    redirect_to :back
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

