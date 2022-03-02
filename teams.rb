class Team 
    attr_reader :name, :posession_frequencies
    attr_accessor :score
    def initialize(name, score, preoff_frequencies, postoff_frequencies)
        @name = name
        @score = score
        @posession_frequencies = posession_frequencies
    end

end