module SSS
  class User < Struct.new(:name)

    def initialize(hash)
      hash.each { |key, value| self[key] = value }
    end

  end
end
