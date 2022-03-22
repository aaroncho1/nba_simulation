class Display
    attr_accessor :possession_results
    def initialize(play)
        @possession_results = []
    end

    def play_by_play
        possession_results.each do |play|
            puts play
        end
    end
end