class Display
    attr_accessor :posession_results, :play
    def initialize(play)
        @posession_results = []
        @play = play
    end

    def play_by_play
        posession_results.each do |play|
            puts play
        end
    end

    def add_play(result)
    end
end