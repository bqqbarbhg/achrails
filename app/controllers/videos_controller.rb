
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

    if shares = params[:share]
      # NOTE: This might be slow, if so find out how to do with only ids
      new_groups = shares.reject { |_, v| v == "0" }
                         .keys.map { |id| Group.find(id) }

      @video.groups.replace(new_groups)
    end

    redirect_to :back
  end

  def destroy
    @video = Video.find(params[:id])
    authorize @video

    @video.destroy

    redirect_to :back
  end

  def share
    @video = Video.find(params[:id])
    authorize @video

    render
  end

protected
  def video_params
    p = params.require(:video).accept(:title)
    p[:author] = current_user
  end
end

