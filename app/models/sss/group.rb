class Group < Struct.new(:id, :name, :memberships, :videos)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end

  def persisted?
    true
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
