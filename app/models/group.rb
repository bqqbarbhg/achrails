class Group < ActiveRecord::Base

  has_many :memberships
  validates :name, presence: true

  def join(user)
    memberships.create(user: user) if user
  end

  def member(user)
    memberships.where(user: user).first if user
  end

  def admin?(user)
    member(user).try(:admin?)
  end

end
