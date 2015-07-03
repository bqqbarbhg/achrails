class Group < ActiveRecord::Base

  has_many :memberships
  has_many :members, through: :memberships, class_name: :user
  validates :name, presence: true

  def join(user)
    memberships.first_or_create(user: user) if user
  end

  def leave(user)
    memberships.delete_all(user: user) if user
  end

  def member(user)
    memberships.find_by(user: user) if user
  end

  def admin?(user)
    member(user).try(:admin?)
  end

end
