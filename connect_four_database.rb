require 'test/unit/assertions.rb'
include Test::Unit::Assertions
require 'mysql'
class ConnectFourDatabase

	def initialize
		@db = Mysql.new("mysqlsrv.ece.ualberta.ca", "group4" , "Bw9pjlUpiEpr", "group4", 13010)
	end

	def reset
		@db.query("DROP TABLE IF EXISTS savedGames")
		@db.query("CREATE TABLE savedGames	\
              (	\
                player1     CHAR(40) NOT NULL,	\
                player2     CHAR(40) NOT NULL,	\
				gameType     CHAR(40) NOT NULL,	\
				PRIMARY KEY ( player1 )	\
              )	\
            ")
	end
	
	def saveGame(player1_, player2_, gameType_)
		#Insert entry into table (overwrite if past saved game exists)
		@db.query("INSERT INTO savedGames(player1, player2, gameType)	\
						VALUES ('#{player1_}', '#{player2_}', '#{gameType_}')	\
					ON DUPLICATE KEY UPDATE	\
						player2 = '#{player2_}',	\
						gameType = '#{gameType_}'")
						
		# Post Conditions 
		#Ensure that there is one entry for our newly inserted saved game
		res = @db.query("SELECT * FROM savedGames WHERE player1 = '#{player1_}'")
		assert(res.num_rows == 1)
		#End Post Conditions						
	end

	def loadGame(player_)
		# Post Conditions 
		# Database has no more than one entry
		res = @db.query("SELECT * FROM savedGames WHERE player1 = '#{player_}'")
		assert(res.num_rows <= 1)
		# End Post Conditions
		
		player2 = nil
		gameType = nil
		res.each_hash do |h| 
			player2 = h['player2']
			gameType = h['gameType']
		end
		
		@db.query("DELETE FROM savedGames WHERE player1 = '#{player_}'")
		
		# Post Conditions 
		# Database does not have it any more.
		res = @db.query("SELECT * FROM savedGames WHERE player1 = '#{player_}'")
		assert(res.num_rows == 0)
		# End Post Conditions
		return player2, gameType
	end

	def addWin(player)
        res = @db.query('SELECT wins FROM results WHERE player = "#{player}";')
        if res.num_rows == 0
            @db.query("INSERT INTO results (player, wins, losses, ties)
                            VALUES ('#{player}', 1, 0, 0);")
        else
            row = res.fetch_row
            wins = row[0] + 1
            @db.query("UPDATE results SET wins = #{wins} WHERE player = '#{player}';")
        end
	end
    
	def addLoss(player)
        res = @db.query('SELECT losses FROM results WHERE player = "#{player}";')
        if res.num_rows == 0
            @db.query("INSERT INTO results (player, wins, losses, ties)
                            VALUES ('#{player}', 0, 1, 0);")
        else
            row = res.fetch_row
            losses = row[0] + 1
            @db.query("UPDATE results SET ties = #{losses} WHERE player = '#{player}';")
        end
	end
    
	def addTie(player)
        res = @db.query('SELECT ties FROM results WHERE player = "#{player}";')
        if res.num_rows == 0
            @db.query("INSERT INTO results (player, wins, losses, ties)
                            VALUES ('#{player}', 0, 0, 1);")
        else
            row = res.fetch_row
            ties = row[0] + 1
            @db.query("UPDATE results SET ties = #{ties} WHERE player = '#{player}';")
        end
	end

	def getLeaderBoard

        res = @db.query('SELECT player, wins, losses, ties FROM results;')
        
        leaderboard = Array.new
        
        while row = res.fetch_row do
            standing = Array.new(row)
            leaderboard.push(standing)
        end
    
        return leaderboard
    
	end
end