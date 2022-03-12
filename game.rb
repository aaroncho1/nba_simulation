require_relative 'display'
require_relative 'teams'
require_relative 'players'
# require 'byebug'

class NbaSimulationGame
    attr_reader :display, :player, :away_team_players, :home_team_players
    attr_accessor :game_clock, :overtime_clock

    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, away_team_players, home_team, home_team_players)
        @away_team, @home_team = away_team, home_team
        @away_team_players, @home_team_players
        @game_clock = 2880
        @overtime_clock = 300
        @offensive_team = nil
        @defensive_team = nil
        @display = Display.new(0)
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

    def made_shot?(result)
        result == "3m" || result == "2m"
    end

    def missed_shot?(result)
        result == "3a" || result == "2a"
    end

    def second_chance_opportunity?
        ind = rand(4)
        if ind == 0
            display.possession_results << "#{@offensive_team.abbreviation} offensive rebound" 
            play_possession
        end
        false 
    end


    def score_ft(result)
        if result == "ftm"
            @offensive_team.score += 1
            display.possession_results << "#{@offensive_team.abbreviation} free throw made #{live_score}" 
        else
            display.possession_results << "#{@offensive_team.abbreviation} free throw missed #{live_score}" 
        end
    end

    def ft_simulation
        2.times do
            ft_result = @offensive_team.get_ft_result
            score_ft(ft_result)
        end
    end

    def bonus?(team)
        team.team_fouls >= 6
    end

    def choose_player(result, team)
        if result == "3m"
            team.select_3pt_shooter
        else
            team.select_2pt_shooter
        end
    end


    def play_possession
        simulate_game_clock
        off_team = @offensive_team
        def_team = @defensive_team
        result = @offensive_team.get_result
        if made_shot?(result)
            score_team(result)
            shooter = choose_player(result, off_team)
            display.possession_results << "#{@offensive_team.abbreviation} #{shooter.name} #{result[0]} pt made #{live_score}"
        elsif missed_shot?(result)
            display.possession_results << "#{@offensive_team.abbreviation} #{result[0]} pt missed #{live_score}"
            second_chance_opportunity?
        elsif result == "sf"
            display.possession_results << "shooting foul"
            ft_simulation
            @defensive_team.team_fouls += 1
        elsif result == "nsf"
            display.possession_results << "non-shooting foul"
            @defensive_team.team_fouls += 1
            ft_simulation if bonus?(@defensive_team)
        elsif result == "to"
            display.possession_results << "#{@offensive_team.abbreviation} turnover"
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

    def game_over?
        game_clock <= 0
    end

    def switch_team
        @offensive_team = @offensive_team == @away_team ? @home_team : @away_team
        @defensive_team = @defensive_team == @away_team ? @home_team : @away_team
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

    def tip_off_simulation
        tip_off_index = rand(2)
        @offensive_team = tip_off_index == 0 ? @away_team : @home_team
        @defensive_team = @offensive_team == @away_team ? @home_team : @away_team
        display.possession_results << "#{@offensive_team.abbreviation} win tipoff"
    end

    def team_fouls_reset
        @away_team.team_fouls = 0
        @home_team.team_fouls = 0
    end

    def team_foul_count
        display.possession_results << "#{@away_team.name} team fouls - #{@away_team.team_fouls}"
        display.possession_results << "#{@home_team.name} team fouls - #{@home_team.team_fouls}"
    end

    def run
        # debugger
        add_players(away_team_players, home_team_players)
        tip_off_simulation
        tip_off_winner = @offensive_team
        until first_quarter_over?
            play_possession
            switch_team
        end
        team_foul_count
        team_fouls_reset
        display.possession_results << "----END OF FIRST QUARTER----"
        @offensive_team = tip_off_winner == @home_team ? @away_team : @home_team
        until second_quarter_over?
            play_possession
            switch_team
        end
        team_foul_count
        team_fouls_reset
        display.possession_results << "----END OF SECOND QUARTER---"
        @offensive_team = tip_off_winner == @home_team ? @away_team : @home_team
        until third_quarter_over?
            play_possession
            switch_team
        end
        team_foul_count
        team_fouls_reset
        display.possession_results << "----END OF THIRD QUARTER----"
        @offensive_team = tip_off_winner == @home_team ? @home_team : @away_team
        until game_over?
            play_possession
            switch_team
        end
        team_foul_count
        end_of_regulation
        play_by_play_results
    end

    def play_by_play_results
        puts "--------PLAY-BY-PLAY--------"
        display.possession_results.each {|play| puts play}
    end

    def add_players(away, home)
        away.each do |player|
            @away_team.add_player(player)
        end
        home.each do |player|
            @home_team.add_player(player)
        end
    end
end

# suns and warriors offensive result frequencies in an array
#2m/a = 2pt fg made/ missed , 3m/a = 3pt made/ missed sf/nsf = shooting/ non shooting foul on other team, or = offensive rebound, to = turnover
suns_frequencies = (["2m"] * 32) + (["2a"] * 30) + (["3m"] * 11) + (["3a"] * 20) + (["sf"] * 7) + (["nsf"] * 2) + (["to"] * 9)
suns_players = [
        Player.new("C. Paul", "PG", 37, (["2a"] * 9) + (["3a"] * 3) + (["sf"] * 2) + (["dr"] * 5) + (["or"] * 1))),
        Player.new("D. Booker", "SG", 38, (["2a"] * 14) + (["3a"] * 7) + (["sf"] * 3) + (["dr"] * 5) + (["or"] * 1))),
        Player.new("M. Bridges", "SF", 38, (["2a"] * 6) + (["3a"] * 4) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1))),
        Player.new("C. Johnson", "PF", 30, (["2a"] * 3) + (["3a"] * 6) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1))),
        Player.new("D. Ayton", "C", 32, (["2a"] * 12) + (["3a"] * 0) + (["sf"] * 1) + (["dr"] * 10) + (["or"] * 3))),
        Player.new("J. Crowder", "SF", 25, (["2a"] * 3) + (["3a"] * 5) + (["sf"] * 1) + (["dr"] * 5) + (["or"] * 1))),
        Player.new("C. Payne", "PG", 20, (["2a"] * 6) + (["3a"] * 4) + (["sf"] * 1) + (["dr"] * 3) + (["or"] * 1))),
        Player.new("F. Kaminsky", "PF", 20, (["2a"] * 5) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1)))
]
warriors_frequencies = (["2m"] * 26) + (["2a"] * 21) + (["3m"] * 14) + (["3a"] * 25) + (["sf"] * 11) + (["nsf"] * 2) + (["to"] * 13)
warriors_players = [
        Player.new("S. Curry", "PG", 37, (["2a"] * 8) + (["3a"] * 12) + (["sf"] * 3) + (["dr"] * 5) + (["or"] * 1)))
        Player.new("K. Thompson", "SG", 35, (["2a"] * 8) + (["3a"] * 8) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1)))
        Player.new("A. Wiggins", "SF", 35, (["2a"] * 9) + (["3a"] * 5) + (["sf"] * 2) + (["dr"] * 4) + (["or"] * 1)))
        Player.new("D. Green", "PF", 37, (["2a"] * 5) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 7) + (["or"] * 1)))
        Player.new("J. Wiseman", "C", 26, (["2a"] * 9) + (["3a"] * 1) + (["sf"] * 1) + (["dr"] * 6) + (["or"] * 1)))
        Player.new("J. Poole", "PG", 34, (["2a"] * 6) + (["3a"] * 7) + (["sf"] * 2) + (["dr"] * 3) + (["or"] * 1)))
        Player.new("J. Kuminga", "PF", 16, (["2a"] * 4) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 3) + (["or"] * 1)))
        Player.new("K. Looney", "C", 20, (["2a"] * 5) + (["3a"] * 0) + (["sf"] * 1) + (["dr"] * 8) + (["or"] * 2)))
]
suns_ft_frequencies = (["ftm"] * 16) + (["fta"] * 4)
warriors_ft_frequencies = (["ftm"] * 16) + (["fta"] * 6)
NbaSimulationGame.new(Team.new("Phoenix Suns", "PHX", 0, suns_frequencies, suns_ft_frequencies), suns_players, Team.new("Golden State Warriors", "GSW", 0, warriors_frequencies, warriors_ft_frequencies), warriors_players).run