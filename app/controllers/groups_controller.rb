
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

protected
  def group_params
    params.require(:group).permit(:name)
  end
end

