
class GroupsController < ApplicationController

  def index
    # TODO: Fix this to another endpoint with videos

    respond_to do |format|
      format.json do
        authenticate_user!
        if sss
          @groups = sss.groups_for(current_user)
          group_json = @groups.map do |group|
            ids = group.videos.map &:uuid
            group.to_h.slice(:name).merge({ videos: ids.as_json })
          end
        else
          @groups = current_user.groups
          group_json = @groups.map do |group|
            ids = group.videos.pluck(:uuid)
            group.as_json.merge({ videos: ids.as_json })
          end
        end
        render json: { groups: group_json }
      end
      format.html do
        if sss
          @groups = sss.groups
        else
          @groups = policy_scope(Group)
        end
        render :index
      end
    end
  end

  def show
    if sss
      @group = sss.group(params[:id])
    else
      @group = Group.find(params[:id])
      authorize @group
    end

    render :show
  end

  def new
    @group = Group.new
    authorize @group, :create?
    
    render :edit
  end

  def create
    if sss
      group_id = sss.create_group(group_params)
    else
      @group = Group.create!(group_params)
      authorize @group
      @group.join(current_user).update(admin: true)
      group_id = @group.id
    end

    redirect_to action: :show, id: group_id
  end

  def update
    # @SSS_Support(edit circles)
    @group = Group.find(params[:id])
    authorize @group

    @group.update(group_params)

    redirect_to action: :show, id: @group.id
  end

  def edit
    # @SSS_Support(edit circles)
    @group = Group.find(params[:id])
    authorize @group
    
    render :edit
  end

  def destroy
    if sss
      group = sss.group(params[:id])
      authorize group
      sss.delete_group(group)
    else
      group = Group.find(params[:id])
      authorize group
      group.destroy
    end

    redirect_to action: :index
  end

  def join
    # @SSS_Support(list all groups)
    @group = Group.find(params[:id])
    authorize @group

    @group.join(current_user)
    redirect_to action: :show, id: @group.id
  end

  def leave
    # @SSS_Support(list all groups)
    @group = Group.find(params[:id])
    authorize @group

    @group.leave(current_user)
    redirect_to action: :show
  end

  def invite
    # TODO (blocked by LL-1189)
    @group = Group.find(params[:id])
    authorize @group

    addresses = params[:address]
    for i, address in addresses
      next unless address.include?('@')
      invitation = Invitation.create(expect_email: address, group: @group)
      next unless invitation

      InvitationMailer.invite_email(invitation).deliver_later
    end

    redirect_to action: :show
  end

protected
  def group_params
    params.require(:group).permit(:name, :visibility)
  end
end

