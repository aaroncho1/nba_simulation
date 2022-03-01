class Display
    attr_accessor :play_by_play, :play
    def initialize(away_score, home_score, play)
        @away_score, @home_score = away_score, home_score
        @play_by_play = []
        @play = play
    end

end