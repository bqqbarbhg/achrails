
class SharesController < ApplicationController
  def index
    @video = Video.find(params[:id])
    authorize @video

    render
  end

  def create
    @video = Video.find(params[:id])
    authorize @video

    @video.groups << Group.find(params[:group])

    respond_to do |format|
      format.json { render json: @video.groups.select(:id).map{|u| u.id.to_s } }
    end
  end

  def destroy
    @video = Video.find(params[:id])
    authorize @video

    @video.groups.destroy(Group.find(params[:group]))

    respond_to do |format|
      format.json { render json: @video.groups.select(:id).map{|u| u.id.to_s } }
    end
  end

end

