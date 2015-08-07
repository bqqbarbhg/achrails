module SSS
  class Video < Struct.new(:uuid, :title, :author)

    def initialize(hash)
      hash.each { |key, value| self[key] = value }
    end

  end
end
