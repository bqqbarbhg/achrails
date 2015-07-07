class VideoPolicy < Struct.new(:user, :video)
  class Scope < Struct.new(:user, :scope)
    def resolve
      # We can avoid using this if we never want to list _all_ the videos
      # directly, better just to enumerate the groups probably.
      # TODO: Implement if needed
      scope
    end
  end

  def index?
    # These will be filtered by Scope
    true
  end

  def show?
    # NOTE: This might be slow, SQL optimize if needed
    video.groups.each do |group|
      return true if Pundit.policy(user, group).show?
    end
    false
  end

  def create?
    # Everyone can create a group
    true
  end

  def update?
    # Only authors are allowed to update their videos
    video.author == user
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def share?
    update?
  end

end

