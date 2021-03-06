require_relative 'display'
require_relative 'teams'
require_relative 'players'
# require 'byebug'

class NbaSimulationGame

    LINE_WIDTH = 61
    PLAYER_COL_WIDTH = 15
    STAT_COL_WIDTH = 6
    attr_reader :display, :player, :away_team_players, :home_team_players
    attr_accessor :game_clock, :overtime_clock

    #1 nba quarter has 720 second quarters * 4 = 2880
    def initialize(away_team, away_team_players, home_team, home_team_players)
        @away_team, @home_team = away_team, home_team
        @away_team_players, @home_team_players = away_team_players, home_team_players
        @game_clock = 2880
        @overtime_clock = 300
        @offensive_team = nil
        @defensive_team = nil
        @display = Display.new(0)
        add_players(away_team_players, home_team_players)
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
            offensive_rebound_simulator(@offensive_team)
            play_possession
        end
        false 
    end


    def score_ft(result, shooter)
        if result == "ftm"
            @offensive_team.score += 1
            display.possession_results << "#{@offensive_team.abbreviation} #{shooter.name} free throw made #{live_score}" 
        else
            display.possession_results << "#{@offensive_team.abbreviation} #{shooter.name} free throw missed #{live_score}" 
        end
    end

    def update_player_stats(result, player)
        if result.include?("2m")
            player.points += 2 
            player.fgm += 1
            player.fga += 1
        elsif result.include?("2a")
            player.fga += 1
        elsif result.include?("3m")
            player.points += 3
            player.fgm += 1
            player.fga += 1
            player.trpm += 1
            player.trpa += 1
        elsif result.include?("3a")
            player.fga += 1
            player.trpa += 1
        elsif result.include?("ftm")
            player.points += 1
            player.ftm += 1
            player.fta += 1
        elsif result.include?("fta")
            player.fta += 1
        elsif result.include?("as")
            player.assists += 1
        elsif result.include?("dr")
            player.rebounds += 1
        elsif result.include?("or")
            player.rebounds += 1
        end
    end

    def ft_simulation
        ft_shooter = choose_player("ft", @offensive_team)
        2.times do
            ft_result = ft_shooter.get_ft_result
            score_ft(ft_result, ft_shooter)
            update_player_stats(ft_result, ft_shooter)
        end
    end

    def bonus?(team)
        team.team_fouls >= 6
    end

    def choose_player(result, team)
        if result.include?("3")
            team.select_three_pt_shooter
        elsif result.include?("2")
            team.select_two_pt_shooter
        elsif result.include?("t")
            team.select_ft_shooter
        elsif result.include?("as")
            team.select_assist_player
        end
    end

    def assisted?
        frequencies = ["y", "n"]
        ind = rand(frequencies.length)
        result = frequencies.shuffle[ind]
        result == "y" ? true : false
    end

    def defensive_rebound_simulator(team)
        rebounding_player = team.select_dr_player
        update_player_stats("dr", rebounding_player)
    end

    def offensive_rebound_simulator(team)
        rebounding_player = team.select_or_player
        display.possession_results << "#{@offensive_team.abbreviation} #{rebounding_player.name} offensive rebound" 
        update_player_stats("or", rebounding_player)
    end
        
    def play_possession
        simulate_game_clock
        result = @offensive_team.get_result
        if made_shot?(result)
            score_team(result)
            made_shooter = choose_player(result, @offensive_team)
            update_player_stats(result, made_shooter)
            display.possession_results << "#{@offensive_team.abbreviation} #{made_shooter.name} #{result[0]} pt made #{live_score}"
            if assisted?
                assisting_player = choose_player("as", @offensive_team)
                update_player_stats("as", assisting_player)
            end
        elsif missed_shot?(result)
            missed_shooter = choose_player(result, @offensive_team)
            update_player_stats(result, missed_shooter)
            display.possession_results << "#{@offensive_team.abbreviation} #{missed_shooter.name} #{result[0]} pt missed #{live_score}"
            defensive_rebound_simulator(@defensive_team)
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
        display_box_score
    end

    def play_by_play_results
        puts "--------PLAY-BY-PLAY--------"
        display.possession_results.each {|play| puts play}
    end

    def display_box_score
        puts ""
        puts "-" * 26 + "BOX SCORE" + "-" * 26
        puts "#{@away_team.name.upcase}"
        puts "#{'PLAYERS'.ljust(PLAYER_COL_WIDTH)} #{'MIN'.ljust(STAT_COL_WIDTH)} #{'FG'.ljust(STAT_COL_WIDTH)} #{'3PT'.ljust(STAT_COL_WIDTH)} #{'FT'.ljust(STAT_COL_WIDTH)} #{'REB'.ljust(STAT_COL_WIDTH)} #{'AST'.ljust(STAT_COL_WIDTH)} #{'PTS'.ljust(STAT_COL_WIDTH)}"
        @away_team.players.each do |player|
            puts "#{player.name.ljust(PLAYER_COL_WIDTH)} #{player.minutes.to_s.ljust(STAT_COL_WIDTH)} #{(player.fgm.to_s + "-" + player.fga.to_s).ljust(STAT_COL_WIDTH)} #{(player.trpm.to_s + "-" + player.trpa.to_s).ljust(STAT_COL_WIDTH)} #{(player.ftm.to_s + "-" + player.fta.to_s).ljust(STAT_COL_WIDTH)} #{player.rebounds.to_s.ljust(STAT_COL_WIDTH)} #{player.assists.to_s.ljust(STAT_COL_WIDTH)} #{player.points.to_s.ljust(STAT_COL_WIDTH)}"
        end
        puts "-" * LINE_WIDTH
        puts "#{@home_team.name.upcase}"
        puts "#{'PLAYERS'.ljust(PLAYER_COL_WIDTH)} #{'MIN'.ljust(STAT_COL_WIDTH)} #{'FG'.ljust(STAT_COL_WIDTH)} #{'3PT'.ljust(STAT_COL_WIDTH)} #{'FT'.ljust(STAT_COL_WIDTH)} #{'REB'.ljust(STAT_COL_WIDTH)} #{'AST'.ljust(STAT_COL_WIDTH)} #{'PTS'.ljust(STAT_COL_WIDTH)}"
        @home_team.players.each do |player|
            puts "#{player.name.ljust(PLAYER_COL_WIDTH)} #{player.minutes.to_s.ljust(STAT_COL_WIDTH)} #{(player.fgm.to_s + "-" + player.fga.to_s).ljust(STAT_COL_WIDTH)} #{(player.trpm.to_s + "-" + player.trpa.to_s).ljust(STAT_COL_WIDTH)} #{(player.ftm.to_s + "-" + player.fta.to_s).ljust(STAT_COL_WIDTH)} #{player.rebounds.to_s.ljust(STAT_COL_WIDTH)} #{player.assists.to_s.ljust(STAT_COL_WIDTH)} #{player.points.to_s.ljust(STAT_COL_WIDTH)}"
        end
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
        Player.new("C. Paul", "PG", 37, (["2a"] * 9) + (["3a"] * 3) + (["sf"] * 2) + (["dr"] * 5) + (["or"] * 1) + (["as"] * 11), (["ftm"] * 8) + (["fta"] * 2)),
        Player.new("D. Booker", "SG", 38, (["2a"] * 14) + (["3a"] * 7) + (["sf"] * 3) + (["dr"] * 5) + (["or"] * 1) + (["as"] * 5), (["ftm"] * 9) + (["fta"] * 1)),
        Player.new("M. Bridges", "SF", 38, (["2a"] * 6) + (["3a"] * 4) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1) + (["as"] * 2), (["ftm"] * 8) + (["fta"] * 2)),
        Player.new("C. Johnson", "PF", 30, (["2a"] * 3) + (["3a"] * 6) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1) + (["as"] * 2), (["ftm"] * 9) + (["fta"] * 1)),
        Player.new("D. Ayton", "C", 32, (["2a"] * 12) + (["3a"] * 0) + (["sf"] * 1) + (["dr"] * 10) + (["or"] * 3) + (["as"] * 1), (["ftm"] * 7) + (["fta"] * 3)),
        Player.new("J. Crowder", "SF", 25, (["2a"] * 3) + (["3a"] * 5) + (["sf"] * 1) + (["dr"] * 5) + (["or"] * 1) + (["as"] * 2), (["ftm"] * 8) + (["fta"] * 2)),
        Player.new("C. Payne", "PG", 20, (["2a"] * 6) + (["3a"] * 4) + (["sf"] * 1) + (["dr"] * 3) + (["or"] * 1) + (["as"] * 5), (["ftm"] * 8) + (["fta"] * 2)),
        Player.new("F. Kaminsky", "PF", 20, (["2a"] * 5) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1) + (["as"] * 1), (["ftm"] * 9) + (["fta"] * 1))
]
warriors_frequencies = (["2m"] * 26) + (["2a"] * 21) + (["3m"] * 14) + (["3a"] * 25) + (["sf"] * 11) + (["nsf"] * 2) + (["to"] * 13)
warriors_players = [
        Player.new("S. Curry", "PG", 37, (["2a"] * 8) + (["3a"] * 12) + (["sf"] * 3) + (["dr"] * 5) + (["or"] * 1) + (["as"] * 6), (["ftm"] * 9) + (["fta"] * 1)),
        Player.new("K. Thompson", "SG", 35, (["2a"] * 8) + (["3a"] * 8) + (["sf"] * 1) + (["dr"] * 4) + (["or"] * 1) + (["as"] * 3), (["ftm"] * 9) + (["fta"] * 1)),
        Player.new("A. Wiggins", "SF", 35, (["2a"] * 9) + (["3a"] * 5) + (["sf"] * 2) + (["dr"] * 4) + (["or"] * 1) + (["as"] * 2), (["ftm"] * 6) + (["fta"] * 4)),
        Player.new("D. Green", "PF", 37, (["2a"] * 5) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 7) + (["or"] * 1) + (["as"] * 7), (["ftm"] * 6) + (["fta"] * 4)),
        Player.new("J. Wiseman", "C", 26, (["2a"] * 9) + (["3a"] * 1) + (["sf"] * 1) + (["dr"] * 6) + (["or"] * 1) + (["as"] * 1), (["ftm"] * 6) + (["fta"] * 4)),
        Player.new("J. Poole", "PG", 34, (["2a"] * 6) + (["3a"] * 7) + (["sf"] * 2) + (["dr"] * 3) + (["or"] * 1) + (["as"] * 4), (["ftm"] * 9) + (["fta"] * 1)),
        Player.new("J. Kuminga", "PF", 16, (["2a"] * 4) + (["3a"] * 2) + (["sf"] * 1) + (["dr"] * 3) + (["or"] * 1) + (["as"] * 1), (["ftm"] * 7) + (["fta"] * 3)),
        Player.new("K. Looney", "C", 20, (["2a"] * 5) + (["3a"] * 0) + (["sf"] * 1) + (["dr"] * 8) + (["or"] * 2) + (["as"] * 2), (["ftm"] * 6) + (["fta"] * 4))
]

NbaSimulationGame.new(Team.new("Phoenix Suns", "PHX", 0, suns_frequencies), suns_players, Team.new("Golden State Warriors", "GSW", 0, warriors_frequencies), warriors_players).run