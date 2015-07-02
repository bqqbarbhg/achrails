class Group < ActiveRecord::Base

  has_many :membersips
  validates :name, presence: true

end
