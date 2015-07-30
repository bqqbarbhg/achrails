
class InvitationsController < ApplicationController

  def show
    authenticate_user!

    @invitation = Invitation.find_by(token: params[:id])
    @group = @invitation.group

    unless @invitation.can_join?(current_user)
      render status: :forbidden
      return
    end

    @group.join(current_user)
    @invitation.destroy
    
    redirect_to @group
  end

protected
end

