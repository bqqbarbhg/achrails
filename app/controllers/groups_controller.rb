
class GroupsController < ApplicationController

  def index
    # TODO: Fix this to another endpoint with videos

    respond_to do |format|
      format.json do
        authenticate_user!
        @groups = current_user.groups
        group_json = @groups.map do |group|
          ids = group.videos.pluck(:uuid)
          group.as_json.merge({ videos: ids.as_json })
        end
        render json: { groups: group_json }
      end
      format.html do
        @groups = policy_scope(Group)
        render :index
      end
    end
  end

  def show
    @group = Group.find(params[:id])
    authorize @group

    render :show
  end

  def new
    @group = Group.new
    authorize @group, :create?
    
    render :edit
  end

  def create
    @group = Group.new(group_params)
    sss.create_group(@group) if sss

    @group.save!
    @group.join(current_user).update(admin: true)

    redirect_to action: :show, id: @group
  end

  def update
    @group = Group.find(params[:id])
    authorize @group

    # @SSS_Support(edit circles)
    @group.update(group_params)

    redirect_to action: :show, id: @group
  end

  def edit
    @group = Group.find(params[:id])
    authorize @group

    # @SSS_Support(edit circles)
    
    render :edit
  end

  def destroy
    group = Group.find(params[:id])
    authorize group
    sss.destroy_group(group) if sss
    group.destroy

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
    @group = Group.find(params[:id])
    authorize @group

    sss.leave_group(@group, current_user) if sss
    @group.leave(current_user)

    redirect_to action: :index
  end

  def invite
    @group = Group.find(params[:id])
    authorize @group

    addresses = params[:address]

    address_list = []

    for i, address in addresses
      next unless address.include?('@')
      invitation = Invitation.create(expect_email: address, group: @group)
      next unless invitation

      address_list.push(address)

      InvitationMailer.invite_email(invitation, @group.name).deliver_later
    end

    flash[:notice] = t('groups.invite.users_invited_message',
                       count: address_list.length, group: @group.name)

    sss.invite_to_group(@group, address_list) if sss and address_list.length > 0

    redirect_to action: :show
  end

protected
  def group_params
    params.require(:group).permit(:name, :description, :visibility)
  end
end

