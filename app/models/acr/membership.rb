unless SSS
class Membership < ActiveRecord::Base
  has_many :memberships
  has_many :groups, through: :memberships, source: :group
  has_many :videos, through: :groups

  has_many :authored_videos, class_name: "Video", foreign_key: :author_id

  belongs_to :user
  belongs_to :group

end
end
