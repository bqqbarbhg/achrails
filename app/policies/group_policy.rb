class GroupPolicy < Struct.new(:user, :group)
  class Scope < Struct.new(:user, :scope)
    def resolve
      # TODO: Filter unlisted groups
      scope.all
    end
  end

  def index?
    # These will be filtered by Scope
    true
  end

  def show?
    # TODO: Filter hidden groups
    true
  end

  def create?
    # Everyone can create a group
    true
  end

  def update?
    # Only group admins are allowed to update skills
    group.admin?(user)
  end

  def destroy?
    # Same as for updating
    update?
  end

  def join?
    # TODO: Should there be a special permission
    # Only non-members can join
    show? && !group.member?(user)
  end

  def leave?
    # Only members can leave, but admins can't leave since
    # they would leave the group orphaned.
    group.member?(user) && !group.admin?(user)
  end

  def invite?
    # All members for now
    group.member?(user)
  end

end

