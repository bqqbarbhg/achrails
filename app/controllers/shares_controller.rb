
class SharesController < ApplicationController
  def index
    @video = Video.find(params[:id])
    authorize @video

    render
  end

  def create
    @video = Video.find(params[:id])
    authorize @video

    # NOTE: This might be slow, but it doesn't seem that there's really any obvious
    # better way to do it.
    group = Group.find(params[:group])
    @video.groups << group unless @video.groups.exists?(group)

    respond_to do |format|
      format.json { render json: @video.group_id_list }
    end
  end

  def destroy
    @video = Video.find(params[:id])
    authorize @video

    @video.groups.destroy(Group.find(params[:group]))

    respond_to do |format|
      format.json { render json: @video.group_id_list }
    end
  end

protected:

end

