class Team 
    attr_reader :name
    attr_accessor :score, :team_fouls, :possession_frequencies, :ft_frequencies
    def initialize(name, score, possession_frequencies, ft_frequencies)
        @name = name
        @score = score
        @possession_frequencies = possession_frequencies
        @ft_frequencies = ft_frequencies
        @team_fouls = 0
    end

    def get_result
        rand_ind = rand(possession_frequencies.length)
        result = possession_frequencies.shuffle[rand_ind]
        result
    end

    def get_ft_result
        rand_ind = rand(ft_frequencies.length)
        result = ft_frequencies.shuffle[rand_ind]
        result
    end
end