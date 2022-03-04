class Display
    attr_accessor :possession_results, :play
    def initialize(play)
        @possession_results = []
        @play = play
    end

    def play_by_play
        possession_results.each do |play|
            puts play
        end
    end
end