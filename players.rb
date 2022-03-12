class Player

    attr_reader :name, :position, :minutes, :frequencies
    attr_accessor :points, :posessions

    def initialize(name, position, minutes, frequencies)
        @name, @position, @minutes, @frequencies   
        @points = 0
        @posessions = []     
    end

end