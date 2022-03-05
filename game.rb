require_relative 'display'
require_relative 'teams'
# require 'byebug'

class NbaSimulationGame
    attr_reader :display
    attr_accessor :game_clock, :overtime_clock, :tip_off_winner

    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, home_team)
        @away_team, @home_team = away_team, home_team
        @game_clock = 2880
        @overtime_clock = 300
        @offensive_team = nil
        @defensive_team = nil
        @display = Display.new(0)
        @tip_off_winner = nil
    end

    def second_chance_result
        "or"
    end

    def shooting_foul
        "sf"
    end

    def score_team(made_shot)
        if made_shot == "3m"
            @offensive_team.score += 3
        elsif made_shot == "2m"
            @offensive_team.score += 2
        end
    end

    def fast_break_time
        random_num = rand(6)
        seconds = (2..7).to_a.shuffle[random_num]
        seconds
    end

    def possession_time
        random_num = rand(17)
        seconds = (8..24).to_a.shuffle[random_num]
        seconds
    end

    def simulate_game_clock
        rand_time = rand(100)
        if rand_time.between?(0,12)
            @game_clock -= fast_break_time
        else    
            @game_clock -= possession_time
        end
    end

    def add_play(result)
        case result
        when "3m", "2m"
            display.possession_results << "#{@offensive_team.abbreviation} #{result[0]} pt made #{live_score}"
        when "3a", "2a"
            display.possession_results << "#{@offensive_team.abbreviation} #{result[0]} pt missed #{live_score}"
        when "nsf"
            display.possession_results << "#{@offensive_team.abbreviation} non-shooting foul"
        when "to"
            display.possession_results << "#{@offensive_team.abbreviation} turnover"
        end
    end

    def play_possession
        result = @offensive_team.get_result
        if result == "3m" || result == "2m"
            score_team(result)
        elsif result == second_chance_result
            display.possession_results << "#{@offensive_team.abbreviation} offensive rebound"
            play_possession
        elsif result == shooting_foul
            display.possession_results << "shooting foul"
            2.times do
                ft_result = @offensive_team.get_ft_result
                if ft_result == "ftm"
                    @offensive_team.score += 1
                    display.possession_results << "#{@offensive_team.abbreviation} free throw made #{live_score}" 
                else
                    display.possession_results << "#{@offensive_team.abbreviation} free throw missed #{live_score}" 
                end
            end
            @defensive_team.team_fouls += 1
        end
        add_play(result)
        simulate_game_clock
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

    def game_over?
        game_clock <= 0
    end

    def tip_off_result
        tip_off_index = rand(2)
        @offensive_team = tip_off_index == 0 ? @away_team : @home_team
        @defensive_team = @offensive_team == @away_team ? @home_team : @away_team
        display.possession_results << "#{@offensive_team.name} win tipoff"
        tip_off_winner = @offensive_team
    end

    def switch_team
        @offensive_team = @offensive_team == @away_team ? @home_team : @away_team
    end

    def tie?
        @away_team.score == @home_team.score
    end

    def live_score
        "  (#{@away_team.score} - #{@home_team.score})"
    end

    def go_to_overtime
        display.possession_results << "----------OVERTIME----------"
        tip_off_result
        until game_over?
            play_possession
            switch_team
        end
        final_score
        go_to_overtime if tie?
    end

    def final_score
        puts "#{@away_team.name} : #{@away_team.score}"
        puts "#{@home_team.name} : #{@home_team.score}"
    end

    def end_of_regulation
        display.possession_results << "------END OF REGULATION-----"
        if tie?
            go_to_overtime
        else
            final_score
        end
    end

    def run
        # debugger
        tip_off_result
        until first_quarter_over?
            play_possession
            switch_team
        end
        display.possession_results << "----END OF FIRST QUARTER----"
        @offensive_team = tip_off_winner == @away_team ? @home_team : @away_team
        until second_quarter_over?
            play_possession
            switch_team
        end
        display.possession_results << "----END OF SECOND QUARTER---"
        @offensive_team = tip_off_winner == @away_team ? @home_team : @away_team
        until third_quarter_over?
            play_possession
            switch_team
        end
        display.possession_results << "----END OF THIRD QUARTER----"
        @offensive_team = tip_off_winner == @away_team ? @away_team : @home_team
        until game_over?
            play_possession
            switch_team
        end
        end_of_regulation
        play_by_play_results
    end

    def play_by_play_results
        puts "--------PLAY-BY-PLAY--------"
        display.possession_results.each {|play| puts play}
    end
end

# suns and warriors offensive result frequencies in an array
#2m/a = 2pt fg made/ missed , 3m/a = 3pt made/ missed sf/nsf = shooting/ non shooting foul on other team, or = offensive rebound, to = turnover
suns_frequencies = (["2m"] * 32) + (["2a"] * 30) + (["3m"] * 11) + (["3a"] * 20) + (["sf"] * 7) + (["nsf"] * 2) + (["or"] * 10) + (["to"] * 9)
warriors_frequencies = (["2m"] * 26) + (["2a"] * 21) + (["3m"] * 14) + (["3a"] * 25) + (["sf"] * 11) + (["nsf"] * 2) + (["or"] * 10) + (["to"] * 13)
suns_ft_frequencies = (["ftm"] * 16) + (["fta"] * 4)
warriors_ft_frequencies = (["ftm"] * 16) + (["fta"] * 6)
NbaSimulationGame.new(Team.new("Phoenix Suns", "PHX", 0, suns_frequencies, suns_ft_frequencies), Team.new("Golden State Warriors", "GSW", 0, warriors_frequencies, warriors_ft_frequencies)).run