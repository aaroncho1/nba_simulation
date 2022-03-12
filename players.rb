class Player

    attr_reader :name, :position, :minutes, :frequencies
    attr_accessor :points, :rebounds, :posessions

    def initialize(name, position, minutes, frequencies)
        @name, @position = name, position  
        @minutes, @frequencies = minutes, frequencies 
        @points = 0
        @rebounds = 0
        @posessions = []     
    end

end