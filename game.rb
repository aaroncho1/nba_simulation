class NbaSimulationGame
    require_relative 'display'
    require_relative 'teams'
    require_relative 'player'
    require 'byebug'

    attr_accessor :game_clock
    attr_reader :display
    
    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, home_team)
        @away_team, @home_team = away_team, home_team
        @players = []
        @game_clock = 2880
        @current_team = @away_team
        @display = Display.new(0, 0, 0)
    end

    def game_over?
        game_clock <= 0
    end

    def play_possession
        
    end

    def tip_off_result
        tip_off_index = rand(2)
        @current_team = tip_off_index == 0 ? @away_team : @home_team
        display.play_by_play << "#{@current_team.name} win tipoff"
    end

    def run
        debugger
        until game_over?
            tip_off_result
            play_possession
        end
    end

end

NbaSimulationGame.new(Team.new("Phoenix Suns"), Team.new("Golden State Warriors")).run