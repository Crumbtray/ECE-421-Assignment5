require 'test/unit/assertions.rb'
include Test::Unit::Assertions
require 'mysql'
class ConnectFourDatabase

	def initialize
		####@db = Mysql.new("mysqlsrv.ece.ualberta.ca", "group1" , "GF2OHhMfWY7s", "C410test", 13010)
	end

	def reset
		@db.query("DROP TABLE IF EXISTS savedGames")
		@db.query("CREATE TABLE savedGames	\
              (	\
                player1     CHAR(40) NOT NULL,	\
                player2     CHAR(40) NOT NULL,	\
				gameType     CHAR(40) NOT NULL,	\
				PRIMARY KEY ( player1 )
              )
            ")
	end
	
	def saveGame(player1_, player2_, gameType_)
		#Insert entry into table (overwrite if past saved game exists)
		@db.query("INSERT INTO savedGames (player1, player2, gameType)	\
						VALUES ('#{player1_}', '#{player2_}', '#{gameType_}')	\
					ON DUPLICATE KEY UPDATE (player2, gameType)	\
						VALUES ('#{player2_}', '#{gameType_}')")
						
		# Post Conditions 
		#Ensure that there is one entry for our newly inserted saved game
		res = @db.query("SELECT * FROM savedGames(player1) VALUES('#{player1_}')")
		assert(res.count == 1)
		#End Post Conditions						
	end

	def loadGame(player_)
		# Post Conditions 
		# Database has no more than one entry
		res = @db.query("SELECT * FROM savedGames(player) VALUES('#{player_}')")
		assert(res.count <= 1)
		# End Post Conditions
		
		player2 = nil
		gameType = nil
		res = @db.query("SELECT * FROM savedGames(player) VALUES('#{player_}')")
		res.each_hash do |h| 
			player2 = h['player2']
			gameType = h['gameType']
		end
		
		@db.query("DELETE FROM savedGames(player) VALUES('#{player_}')")
		
		# Post Conditions 
		# Database does not have it any more.
		res = @db.query("SELECT * FROM savedGames(player) VALUES('#{player_}')")
		assert(res.count == 0)
		# End Post Conditions
	end

	def addWin(player, result)
        res = @db.query('select wins from results WHERE player = "#{player}"')
        if res.num_rows == 0
            @db.query("INSERT INTO results (player, wins, losses, ties)
                            VALUES ('#{player}', 1, 0, 0);")
        else
            row = res.fetch_row
            wins = row[0] + 1
            @db.query("UPDATE results SET wins = #{wins} WHERE player = '#{player}';")
        end
	end
    
	def addLoss(player, result)
        res = @db.query('select losses from results WHERE player = "#{player}"')
        if res.num_rows == 0
            @db.query("INSERT INTO results (player, wins, losses, ties)
                            VALUES ('#{player}', 0, 1, 0);")
        else
            row = res.fetch_row
            losses = row[0] + 1
            @db.query("UPDATE results SET ties = #{losses} WHERE player = '#{player}';")
        end
	end
    
	def addTie(player, result)
        res = @db.query('select ties from results WHERE player = "#{player}"')
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

	end
end