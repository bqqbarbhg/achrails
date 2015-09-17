
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

    respond_to do |format|
      format.html { redirect_to action: :index }
      format.json { render nothing: true, status: :no_content }
    end
  end

  def join
    # @SSS_Support(list all groups)
    @group = Group.find(params[:id])
    authorize @group

    @group.join(current_user)
    redirect_to action: :show, id: @group.id
  end

  def leave
    if sss
      @group = sss.group(params[:id])
      authorize @group

      sss.leave_group(@group, current_user)
    else
      @group = Group.find(params[:id])
      authorize @group

      @group.leave(current_user)
    end
    redirect_to action: :index
  end

  def invite
    if sss
      @group = sss.group(params[:id])
    else
      @group = Group.find(params[:id])
    end
    authorize @group

    addresses = params[:address]

    address_list = []

    for i, address in addresses
      next unless address.include?('@')
      if sss
        invitation = Invitation.create(expect_email: address, sss_group: @group.id)
      else
        invitation = Invitation.create(expect_email: address, group: @group)
      end
      next unless invitation

      address_list.push(address)

      InvitationMailer.invite_email(invitation, @group.name).deliver_later
    end

    flash[:notice] = t(:users_invited, count: address_list.length, group: @group.name)

    if sss
      sss.invite_to_group(@group, address_list) if address_list.length > 0
    end

    redirect_to action: :show
  end

protected
  def group_params
    params.require(:group).permit(:name, :description, :visibility)
  end
end

