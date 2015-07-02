class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :memberships

  def name
    email.split('@')[0].gsub(/\W+/, ' ').gsub(/[\d_]+/, '').titlecase
  end

end
