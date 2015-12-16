ShareGroup = Struct.new(:group, :shared, :shareclass)

class SharesController < ApplicationController

  def index
    ids = params[:id].split(',')
    @videos = Video.where(uuid: ids)

    @videos.each do |video|
      authorize video, :share?
    end

    @groups = current_user.groups

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

    # HACK: Updating the sharing of a video does not refresh the token, so
    # force authentication to make sure we can do SSS requests later in
    # client Javascript. If they fail just reload the page.
    # See views/shares/index.html.erb
    sss.force_authenticate() if sss

    render
  end

  def create
    ids = params[:id].split(',')

    @videos = Video.where(uuid: ids)
    group = Group.find(params[:group])
    authorize group, :share?

    @videos.each do |video|
      authorize video, :share?
    end

    sss.group_add_videos(group, @videos) if sss

    # NOTE: This might be slow, but it doesn't seem that there's really any obvious
    # better way to do it.
    @videos.each do |video|
      video.groups << group unless video.groups.exists?(group)
    end

    respond_to do |format|
      format.json { render json: { shared: true, ids: ids } }
    end
  end

  def destroy
    ids = params[:id].split(',')

    @videos = Video.where(uuid: ids)
    group = Group.find(params[:group]) 

    sss.group_remove_videos(group, @videos) if sss

    @videos.each do |video|
      authorize video, :share?
      video.groups.destroy(group)
    end

    respond_to do |format|
      format.json { render json: { shared: false, ids: ids } }
    end
  end

  def set_publicity
    is_public = params[:isPublic]
    ids = params[:id].split(',')

    Video.where(uuid: ids).each do
      authorize video, :share?
    end

    sss.set_videos_publicity(ids, is_public) if sss
    Video.where(uuid: ids).update_all(is_public: is_public)

    render json: {isPublic: is_public}
  end

protected

end

