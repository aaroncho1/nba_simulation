require_relative 'display'
require_relative 'teams'
require 'byebug'

class NbaSimulationGame

    attr_accessor :game_clock
    attr_reader :display

    
    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, home_team)
        @away_team, @home_team = away_team, home_team
        @game_clock = 2880
        @offensive_team = nil
        @defensive_team = nil
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

    def score_team(made_shot)
        if made_shot == "3m"
            @offensive_team.score += 3
        elsif made_shot == "2m"
            @offensive_team.score += 2
        else   
            @offensive_team.score += 1
        end
    end

    def play_possession
        result = @offensive_team.get_result
        display.add_play(result)
        if result == "3m" || result == "2m"
            score_team(result)
        elsif result == second_chance_result
            play_possession
        elsif result == foul
            2.times do
            @offensive_team.get_ft_result
            end
            @defensive_team.team_fouls += 1
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
        @offensive_team = tip_off_index == 0 ? @away_team : @home_team
        @defensive_team = @offensive_team == @away_team ? @home_team : @away_team
        display.posession_results << "#{@offensive_team.name} win tipoff"
        @offensive_team
    end

    def run
        debugger
        tip_off_result
        until first_quarter_over?
            play_possession
            switch_team
        end
        @offensive_team = tip_off_result == @away_team ? @home_team : @away_team
        until second_quarter_over?
            play_possession
            switch_team
        end
        @offensive_team = tip_off_result == @away_team ? @home_team : @away_team
        until third_quarter_over?
            play_possession
            switch_team
        end
        @offensive_team = tip_off_result == @away_team ? @away_team : @home_team
        until game_over?
            play_possession
            switch_team
        end
    end
end

# suns and warriors offensive result frequencies in an array
#2m/a = 2pt fg made/ missed , 3m/a = 3pt made/ missed sf/nsf = shooting/ non shooting foul on other team, or = offensive rebound, to = turnover
suns_frequencies = (["2m"] * 32) + (["2a"] * 30) + (["3m"] * 11) + (["3a"] * 20) + (["sf"] * 7) + (["nsf"] * 2) + (["or"] * 10) + (["to"] * 9)
warriors_frequencies = (["2m"] * 26) + (["2a"] * 21) + (["3m"] * 14) + (["3a"] * 25) + (["f"] * 11) + (["nsf"] * 2) (["or"] * 10) + (["to"] * 13)
suns_ft_frequencies = (["ftm"] * 16) + (["fta"] * 4)
warriors_ft_frequencies = (["ftm"] * 16) + (["fta"] * 6)
NbaSimulationGame.new(Team.new("Phoenix Suns", 0, suns_frequencies, suns_ft_frequencies), Team.new("Golden State Warriors", 0, warriors_frequencies, warriors_ft_frequencies)).run