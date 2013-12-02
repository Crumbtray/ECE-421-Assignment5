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

	def updateLeaderBoard(player, result)
		
	end

	def getLeaderBoard

	end
end