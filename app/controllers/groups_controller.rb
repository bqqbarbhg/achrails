
class GroupsController < ApplicationController

  def index
    @groups = Group.all
    render :index
  end

  def show
    @group = Group.find(params[:id])
    render :show
  end

  def create
    @group = Group.create!(group_params)
    @group.join(current_user).update(admin: true)

    redirect_to action: :show, id: @group.id
  end

  def destroy
    group = Group.find(params[:id])
    group.delete if group.admin?(current_user)

    redirect_to action: :index
  end

  def join
    @group = Group.find(params[:id])
    @group.join(current_user)

    redirect_to action: :show, id: @group.id
  end

  def leave
    @group = Group.find(params[:id])
    @group.leave(current_user)

    redirect_to action: :show
  end

  def invite
    @group = Group.find(params[:id])
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

