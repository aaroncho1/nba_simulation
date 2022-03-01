class NbaSimulationGame
    require_relative 'display'
    require_relative 'teams'
    require_relative 'player'

    attr_accessor :game_clock
    
    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize
        @teams = []
        @players = []
        @game_clock = 2880
    end

    def game_over?
        game_clock <= 0
    end

    def run
        until game_over?
        end
    end

end