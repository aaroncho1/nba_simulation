class Team 
    attr_reader :name, :posession_frequencies
    attr_accessor :score
    def initialize(name, score, possession_frequencies, ft_frequencies)
        @name = name
        @score = score
        @posession_frequencies, @ft_frequencies = posession_frequencies, ft_frequencies
    end

    def get_result
    end

end