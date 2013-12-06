require 'test/unit/assertions.rb'
include Test::Unit::Assertions
require 'mysql'
class ConnectFourDatabase

	def initialize
		####@db = Mysql.new("mysqlsrv.ece.ualberta.ca", "group1" , "GF2OHhMfWY7s", "C410test", 13010)
	end

	def saveGame(game)
		# Pre conditions
		# Make sure that the game hasn't ended.
		begin
			raise ArgumentError, "Game has ended." unless game.gameBoard.endGame == false
		end
		# End Pre Conditions

	end

	def loadGame(gameId)
		res = @db.query('select * from animal')
		#Pre conditions
			# Make sure that it exists in the database.
			assert(res.num_rows == 1)
		# End Pre conditions

		# Post Conditions 
			# Database does not have it any more.
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