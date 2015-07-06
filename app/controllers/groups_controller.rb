
class GroupsController < ApplicationController

  def index
    @groups = Group.all
    render :index
  end

  def show
    @group = Group.find(params[:id])
    authorize @group

    render :show
  end

  def new
    @group = Group.new
    
    render :edit
  end

  def create
    @group = Group.create!(group_params)
    authorize @group

    @group.join(current_user).update(admin: true)

    redirect_to action: :show, id: @group.id
  end

  def update
    @group = Group.find(params[:id])
    authorize @group

    @group.update(group_params)

    redirect_to action: :show, id: @group.id
  end

  def edit
    @group = Group.find(params[:id])
    authorize @group
    
    render :edit
  end

  def destroy
    group = Group.find(params[:id])
    authorize @group

    group.destroy
    redirect_to action: :index
  end

  def join
    @group = Group.find(params[:id])
    authorize @group

    @group.join(current_user)
    redirect_to action: :show, id: @group.id
  end

  def leave
    @group = Group.find(params[:id])
    authorize @group

    @group.leave(current_user)
    redirect_to action: :show
  end

  def invite
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
    params.require(:group).permit(:name)
  end
end

