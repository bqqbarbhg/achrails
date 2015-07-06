class GroupPolicy < Struct.new(:user, :group)
  class Scope < Struct.new(:user, :scope)
    def resolve
      # Show only groups we are a member of and ones that are publicly listed
      scope.joins(:memberships)
           .where('memberships.user_id = ? OR visibility = ?', user, 2)
    end
  end

  def index?
    # These will be filtered by Scope
    true
  end

  def show?
    group.public_show? || group.member?(user)
  end

  def create?
    # Everyone can create a group
    true
  end

  def update?
    # Only group admins are allowed to update skills
    group.admin?(user)
  end

  def edit?
    update?
  end

  def destroy?
    # Same as for updating
    update?
  end

  def join?
    # Only non-members can join
    show? && !group.member?(user)
  end

  def leave?
    # Only members can leave, but admins can't leave since
    # they would leave the group orphaned.
    group.member?(user) && !group.admin?(user)
  end

  def invite?
    # Only admins
    group.admin?(user)
  end

end

