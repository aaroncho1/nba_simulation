class Display
    attr_accessor :play_by_play, :play
    def initialize(play)
        @play_by_play = []
        @play = play
    end
end