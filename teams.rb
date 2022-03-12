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

    def select_three_pt_shooter
        three_pt_frequencies = []
        @players.each do |player|
            three_pt_frequencies << player * player.frequencies.select{|stat| stat.include?("3")}.count
        end
        rand_ind = rand(three_pt_frequencies.length)
        shooter = three_pt_frequencies.shuffle[rand_ind]
        shooter
    end

    def select_two_pt_shooter
        two_pt_frequencies = []
        @players.each do |player|
            two_pt_frequencies << player * player.frequencies.select{|stat| stat.include?("2")}.count
        end
        rand_ind = rand(two_pt_frequencies.length)
        shooter = two_pt_frequencies.shuffle[rand_ind]
        shooter
    end
end