class DumbAI
	def initialize
		# We can instantiate stuff here if need be.
		# Make the AI learn, etc.
	end

	#DumbAI will naively choose its next move randomly from the unfilled board columns
	def makeMove(gameInstance)
		gameBoard = gameInstance.gameBoard

		# Pre Conditions
		begin
			raise ArgumentError, "DumbAI:: ArgumentError -> Game is over.  Please start a new one." unless gameBoard.endGame == false
		end
		# End Pre Conditions
		
		possibleMoves = Array.new
		#Add non-full columns to choice list
		for index in 0..gameBoard.colSize - 1
			if gameBoard.grid[index].to_a.count < gameBoard.rowSize
				possibleMoves.push(index + 1)
			end
		end
		#Randomly chose from filtered columns
		return gameInstance.move(self, possibleMoves.sample)
	end

	def updateGrid(location, player)

	end
end