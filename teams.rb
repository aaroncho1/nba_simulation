class Team 
    attr_reader :name, :abbreviation
    attr_accessor :score, :team_fouls, :possession_frequencies, :ft_frequencies, :players
    def initialize(name, abbreviation, score, possession_frequencies, ft_frequencies)
        @name = name
        @abbreviation = abbreviation
        @score = score
        @possession_frequencies = possession_frequencies
        @ft_frequencies = ft_frequencies
        @team_fouls = 0
        @players = []
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

    def add_player(player)
        @players << player
    end
end