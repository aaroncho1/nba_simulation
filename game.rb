class NbaSimulationGame
    require_relative 'display'
    require_relative 'teams'
    require_relative 'player'

    attr_accessor :game_clock
    
    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, home_team)
        @away_team, @home_team = away_team, home_team
        @players = []
        @game_clock = 2880
        @current_team = @away_team
    end

    def game_over?
        game_clock <= 0
    end

    def play_possession
    end

    def run
        until game_over?
            play_possession
        end
    end

end