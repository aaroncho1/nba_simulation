class Team 
    attr_reader :name, :abbreviation
    attr_accessor :score, :team_fouls, :possession_frequencies, :players
    def initialize(name, abbreviation, score, possession_frequencies)
        @name = name
        @abbreviation = abbreviation
        @score = score
        @possession_frequencies = possession_frequencies
        @team_fouls = 0
        @players = []
    end

    def get_result
        rand_ind = rand(possession_frequencies.length)
        result = possession_frequencies.shuffle[rand_ind]
        result
    end

    def add_player(player)
        @players << player
    end

    def select_three_pt_shooter
        three_pt_frequencies = []
        @players.each do |player|
            three_pt_frequencies << [player] * player.frequencies.select{|stat| stat.include?("3")}.count
        end
        flattened_frequencies = three_pt_frequencies.flatten
        rand_ind = rand(flattened_frequencies.length)
        shooter = flattened_frequencies.shuffle[rand_ind]
        shooter
    end

    def select_two_pt_shooter
        two_pt_frequencies = []
        @players.each do |player|
            two_pt_frequencies << [player] * player.frequencies.select{|stat| stat.include?("2")}.count
        end
        flattened_frequencies = two_pt_frequencies.flatten
        rand_ind = rand(flattened_frequencies.length)
        shooter = flattened_frequencies.shuffle[rand_ind]
        shooter
    end

    def select_ft_shooter
        ft_freqs = []
        @players.each do |player|
            ft_freqs << [player] * player.frequencies.select{|stat| stat.include?("sf")}.count
        end
        flattened_frequencies = ft_freqs.flatten
        rand_ind = rand(flattened_frequencies.length)
        shooter = flattened_frequencies.shuffle[rand_ind]
        shooter
    end

    def select_assist_player
        as_freqs = []
        @players.each do |player|
            as_freqs << [player] * player.frequencies.select{|stat| stat.include?("as")}.count
        end
        flattened_frequencies = as_freqs.flatten
        rand_ind = rand(flattened_frequencies.length)
        assistor = flattened_frequencies.shuffle[rand_ind]
        assistor
    end
end