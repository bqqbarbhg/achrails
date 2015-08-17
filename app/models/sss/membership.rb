if SSS
class Membership < Struct.new(:user, :group, :admin?)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
end
end
