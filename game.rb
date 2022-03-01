class NbaSimulationGame
    require_relative 'display'
    require_relative 'teams'
    require_relative 'player'

    def initialize
        @teams = []
        @players = []
    end

    def run
        until game_over?
        end
    end

end