
class GroupsController < ApplicationController

  def index
    @groups = policy_scope(Group)
    respond_to do |format|
      format.json { render json: { groups: @groups.map(&:collection_json) } }
      format.html { render :index }
    end
  end

  def own
    authenticate_user!
    @groups = current_user.groups
    respond_to do |format|
      format.json do
        render json: {
          groups: @groups.map(&:collection_json),
          user: current_user.manifest_json,
        }
      end
      format.html { render :index }
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
    authenticate_user!

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
      if current_user
        InvitationMailer.invite_email(invitation, @group.name, current_user.name).deliver_later
      end
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

