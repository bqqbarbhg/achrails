
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

  def add_webhook
    authenticate_user!
    group = Group.find(params[:id])
    authorize group

    url = params[:notification_url]
    type = params[:event_type]

    if Webhook::validate_event_type(type) and Webhook::validate_url(url)
      webhook = Webhook.new(notification_url: url, event_type: type)
      group.webhooks << webhook
      redirect_to group
    else
      head :bad_request
    end
  end

  def delete_webhook
    authenticate_user!
    group = Group.find(params[:id])
    authorize group

    webhook = Webhook.find(params[:webhook_id])

    if webhook
      webhook.destroy
      redirect_to group
    else
      head :not_found
    end
  end

  def update_webhook
    authenticate_user!
    group = Group.find(params[:id])
    authorize group

    webhook = Webhook.find(params[:webhook_id])

    url = params[:notification_url]
    type = params[:event_type]

    if Webhook::validate_event_type(type) and Webhook::validate_url(url)
      webhook.update(notification_url: url, event_type: type)
      head :ok
    else
      head :bad_request
    end

  end

  def create
    authenticate_user!

    @group = Group.new(group_params)
    sss.create_group(@group) if sss

    @group.save!
    @group.join(current_user).update(admin: true)

    log_event(:create_group, @group)

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

    log_event(:delete_group, group)

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

    log_event(:join_group, @group)

    @group.join(current_user)
    redirect_to action: :show, id: @group.id
  end

  def leave
    @group = Group.find(params[:id])
    authorize @group

    log_event(:leave_group, @group)

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
      address_to_invite = address

      # No ad-sign, check if we're attempting to add by Layers account
      if not address_to_invite.include?('@')
       user_to_invite =  User.find_by preferred_username: address
        if not user_to_invite.blank?
          address_to_invite = user_to_invite.email
        else
          next
        end
      else
      end

      invitation = Invitation.create(expect_email: address_to_invite, group: @group)
      next unless invitation

      address_list.push(address_to_invite)
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

