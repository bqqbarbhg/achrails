
class SharesController < ApplicationController
  def index
    ids = params[:id].split(',')
    @videos = Video.where(uuid: ids)
    @videos.each do |video|
      authorize video, :share?
    end

    render
  end

  def create
    ids = params[:id].split(',')
    @videos = Video.where(uuid: ids)

    group = Group.find(params[:group])
    authorize group, :share?

    # NOTE: This might be slow, but it doesn't seem that there's really any obvious
    # better way to do it.
    @videos.each do |video|
      authorize video, :share?
      video.groups << group unless video.groups.exists?(group)
    end

    respond_to do |format|
      # TODO: Figure out a response format
      format.json { render json: { } }
    end
  end

  def destroy
    ids = params[:id].split(',')
    @videos = Video.where(uuid: ids)

    @videos.each do |video|
      authorize video, :share?
      video.groups.destroy(Group.find(params[:group]))
    end

    respond_to do |format|
      # TODO: Figure out a response format
      format.json { render json: { } }
    end
  end

protected

end

