module SSS
  class Group < Struct.new(:id, :name, :memberships, :videos)

    def initialize(hash)
      hash.each { |key, value| self[key] = value }
    end

    def members
      memberships.map &:user
    end
  end
end
