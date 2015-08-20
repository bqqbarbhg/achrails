if SSS
class Person < Struct.new(:id, :name, :email)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
end
end
