class Video < ActiveRecord::Base

  belongs_to :author, class_name: "User"
  has_and_belongs_to_many :groups, uniq: true

  validates :title, presence: true

end
