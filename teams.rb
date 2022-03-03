class Team 
    attr_reader :name, :posession_frequencies, :ft_frequencies
    attr_accessor :score, :team_fouls
    def initialize(name, score, possession_frequencies, ft_frequencies)
        @name = name
        @score = score
        @posession_frequencies, @ft_frequencies = posession_frequencies, ft_frequencies
        @team_fouls = 0
    end

    def get_result
        rand_ind = rand(posession_frequencies.length)
        result = posession_frequencies.shuffle[rand_ind]
        result
    end

    def get_ft_result
        rand_ind = rand(ft_frequencies.length)
        result = ft_frequencies.shuffle[rand_ind]
        result
    end
end