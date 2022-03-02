class Team 
    attr_reader :name
    attr_accessor :score
    def initialize(name, score)
        @name = name
        @score = score
    end
end