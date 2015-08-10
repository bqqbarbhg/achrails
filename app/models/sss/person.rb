class Person < Struct.new(:id, :name)
  include ActiveModel::Model
  def initialize(hash)
    hash.each { |key, value| self[key] = value }
  end
end
