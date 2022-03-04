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

    def add_play(result)
        case result
        when "3m", "2m"
            possession_results << "#{result[0]} pt made"
        when "3a", "2a"
            possession_results << "#{result[0]} pt missed"
        when "sf"
            possession_results << "shooting foul"
        when "nsf"
            possession_results << "non-shooting foul"
        when "or" 
            possession_results << "offensive rebound"
        when "to"
            possession_results << "turnover"
        end
    end
end