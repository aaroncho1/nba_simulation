class Player

    attr_reader :name, :position, :minutes, :frequencies, :ft_per
    attr_accessor :points, :rebounds, :posessions

    def initialize(name, position, minutes, frequencies, ft_per)
        @name, @position = name, position  
        @minutes, @frequencies = minutes, frequencies 
        @ft_per = ft_per
        @points = 0
        @rebounds = 0
        @assists = 0
        @posessions = []     
    end

    def get_ft_result
        ind = rand(ft_per.length)
        result = ft_per.shuffle[ind]
        result
    end
end