class NbaSimulationGame
    require_relative 'display'
    require_relative 'teams'
    require 'byebug'

    attr_accessor :game_clock
    attr_reader :display

    
    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, home_team)
        @away_team, @home_team = away_team, home_team
        @game_clock = 2880
        @current_team = @home_team
        @display = Display.new(0)
    end

    def second_chance_result
        "or"
    end

    def foul
        "f"
    end

    def game_over?
        game_clock <= 0
    end

    def play_possession
        result = @current_team.get_result
        display.
        play_posession if result == second_chance_result
        if result == foul
            2.times do
            @current_team.get_ft_result
            end
        end
    end

    def first_quarter_over?
        game_clock <= 2160
    end

    def second_quarter_over?
        game_clock <= 1440
    end

    def third_quarter_over?
        game_clock <= 720
    end

    def tip_off_result
        tip_off_index = rand(2)
        @current_team = tip_off_index == 0 ? @away_team : @home_team
        display.posession_results << "#{@current_team.name} win tipoff"
        @current_team
    end

    def run
        debugger
        tip_off_result
        until first_quarter_over?
            play_possession
            switch_team
        end
        @current_team = tip_off_result == @away_team ? @home_team : @away_team
        until second_quarter_over?
            play_possession
            switch_team
        end
        @current_team = tip_off_result == @away_team ? @home_team : @away_team
        until third_quarter_over?
            play_possession
            switch_team
        end
        @current_team = tip_off_result == @away_team ? @away_team : @home_team
        until game_over?
            play_possession
            switch_team
        end
    end
end

# suns and warriors offensive result frequencies in an array
#2m/a = 2pt fgm/ fga , 3m/a = 3pt, f = foul on other teams, or = offensive rebound, to = turnover
suns_frequencies = (["2m"] * 32) + (["2a"] * 62) + (["3m"] * 11) + (["3a"] * 31) + (["f"] * 7) + (["or"] * 10) + (["to"] * 9)
warriors_frequencies = (["2m"] * 26) + (["2a"] * 47) + (["3m"] * 14) + (["3a"] * 39) + (["f"] * 11) + (["or"] * 10) + (["to"] * 13)
suns_ft_frequencies = (["ftm"] * 16) + (["fta"] * 20)
warriors_ft_frequencies = (["ftm"] * 16) + (["fta"] * 22)
NbaSimulationGame.new(Team.new("Phoenix Suns", 0, suns_frequencies, suns_ft_frequencies), Team.new("Golden State Warriors", 0, warriors_frequencies, warriors_ft_frequencies)).run