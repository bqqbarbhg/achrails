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

    respond_to do |format|
      format.json { render json: { shared: true, ids: ids } }
      format.html { render nothing: true, status: :ok }
    end

    # NOTE: This might be slow, but it doesn't seem that there's really any obvious
    # better way to do it.
    @videos.each do |video|
      unless video.groups.exists?(group)
        video.groups << group
        group.new_video_call_webhook(video, current_user)
        log_event(:share_video, video, group.id, 1)

        group.members.each do |member|
            member.notify_user("New video to group " + group.name, "User " +
                               current_user.name  + " shared a new video!")
        end
      end
    end
  end

  def destroy
    ids = params[:id].split(',')

    @videos = Video.where(uuid: ids)
    group = Group.find(params[:group]) 

    sss.group_remove_videos(group, @videos) if sss

    @videos.each do |video|
      authorize video, :share?
      if video.groups.exists?(group)
        video.groups.destroy(group)
        log_event(:share_video, video, group.id, 0)
      end
    end

    respond_to do |format|
      format.json { render json: { shared: false, ids: ids } }
      format.html { render nothing: true, status: :ok }
    end
  end

  def set_publicity
    is_public = params[:isPublic]
    ids = params[:id].split(',')

    videos = Video.where(uuid: ids)
    
    videos.each do |video|
      authorize video, :share?
    end

    sss.set_videos_publicity(ids, is_public) if sss
    Video.where(uuid: ids).update_all(is_public: is_public)

    videos.each do |video|
      log_event(:publish_video, video, nil, is_public ? 1 : 0)
    end

    render json: {isPublic: is_public}
  end

protected

end

