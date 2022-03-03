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
        case result
        when "3m", "2m"
            posession_results << "#{result[0]} pt made"
        when "3a", "2a"
            posession_results << "#{result[0]} pt missed"
        when "sf"
            posession_results << "shooting foul"
        when "nsf"
            posession_results << "non-shooting foul"
        when "or" 
            posession_results << "offensive rebound"
        when "to"
            posession_results << "turnover"
        end
    end
end