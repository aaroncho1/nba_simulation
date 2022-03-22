class Player

    attr_reader :name, :position, :minutes, :frequencies, :ft_per
    attr_accessor :points, :rebounds, :assists, :fgm, :fga, :trpm, :trpa, :ftm, :fta 

    def initialize(name, position, minutes, frequencies, ft_per)
        @name, @position = name, position  
        @minutes, @frequencies = minutes, frequencies 
        @ft_per = ft_per
        @points = 0
        @rebounds = 0
        @assists = 0
        @fgm = 0
        @fga = 0
        @trpm = 0
        @trpa = 0
        @ftm = 0 
        @fta = 0  
    end

    def get_ft_result
        ind = rand(ft_per.length)
        result = ft_per.shuffle[ind]
        result
    end
end