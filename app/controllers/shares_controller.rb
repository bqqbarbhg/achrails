ShareGroup = Struct.new(:group, :shared, :shareclass)

class SharesController < ApplicationController
  def index
    ids = params[:id].split(',')
    @videos = Video.where(uuid: ids)
    @videos.each do |video|
      authorize video, :share?
    end

    @share_groups = current_user.groups.map do |group|
      shared = @videos.map do |video|
        video.groups.where(id: group.id).count > 0
      end

      shareclass = if shared.any? { |x| x != shared.first }
        :mixed # There are both shared and unshared videos
      elsif shared.first
        :shared # They are all the same so all must be shared
      else
        :unshared # Applies to unshared too
      end

      ShareGroup.new(group, shared, shareclass)
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

