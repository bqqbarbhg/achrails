if SSS
class Group < Struct.new(:id, :name, :memberships, :videos)
  include ActiveModel::Model
  def initialize(hash=nil)
    @persisted = !!hash
    hash.each { |key, value| self[key] = value } if hash
  end

  def persisted?
    @persisted
  end

  def members
    memberships.map &:user
  end
  def membership_for(user)
    person = user.person
    memberships.select { |membership| membership.user == person }.first
  end

  def member?(user)
    membership_for(user)
  end
  def admin?(user)
    membership_for(user).try :admin?
  end
  def public_show?
    true
  end
end
end
