SHOT_MADE = ["2m", "3m"]

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
        if SHOT_MADE.include?(result)
            posession_results << "#{result[0]} pt made"
        elsif result == "f"
            posession_results << "shooting foul"

    end
end