ShareGroup = Struct.new(:group, :shared, :shareclass)

class SharesController < ApplicationController
  def index
    ids = params[:id].split(',')
    if sss
      @videos = sss.videos.select { |video| ids.include?(video.uuid) }
    else
      @videos = Video.where(uuid: ids)
    end

    @videos.each do |video|
      authorize video, :share?
    end

    if sss
      @groups = sss.groups
    else
      @groups = current_user.groups
    end

    @share_groups = @groups.map do |group|
      shared = @videos.map do |video|
        group.has_video?(video)
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

    if sss
      @videos = sss.videos.select { |video| ids.include?(video.uuid) }
      group = sss.group(params[:group])
      authorize group, :share?
      @videos.each do |video|
        authorize video, :share?
      end

      sss.group_add_videos(group, @videos)
    else
      @videos = Video.where(uuid: ids)
      group = Group.find(params[:group])
      authorize group, :share?

      # NOTE: This might be slow, but it doesn't seem that there's really any obvious
      # better way to do it.
      @videos.each do |video|
        authorize video, :share?
        video.groups << group unless video.groups.exists?(group)
      end
    end

    respond_to do |format|
      format.json { render json: { shared: true, ids: ids } }
    end
  end

  def destroy
    ids = params[:id].split(',')

    if sss
      @videos = sss.videos.select { |video| ids.include?(video.uuid) }
      group = sss.group(params[:group])
      authorize group, :share?
      @videos.each do |video|
        authorize video, :share?
      end

      sss.group_remove_videos(group, @videos)
    else
      @videos = Video.where(uuid: ids)
      @videos.each do |video|
        authorize video, :share?
        video.groups.destroy(Group.find(params[:group]))
      end
    end

    respond_to do |format|
      format.json { render json: { shared: false, ids: ids } }
    end
  end

protected

end

