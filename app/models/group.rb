class Group < ActiveRecord::Base

  has_many :memberships
  validates :name, presence: true

  def join(user)
    memberships.where(user: user).first_or_create if user
  end

  def leave(user)
    memberships.where(user: user).delete_all if user
  end

  def member(user)
    memberships.where(user: user).first if user
  end

  def admin?(user)
    member(user).try(:admin?)
  end

end
