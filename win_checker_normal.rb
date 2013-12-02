module WinCheckerNormal
	def self.checkWinCondition(gameBoard)
		#Pre Conditions
		begin
			raise ArgumentError, "WinCheckerToot:: ArgumentError -> Game is over.  Please start a new one." unless gameBoard.endGame == false
		end
		# End Pre Conditions

		anyOpenSpace = false
		for x in 0..gameBoard.colSize - 1
			for y in 0..gameBoard.rowSize - 1
				current = gameBoard.grid[x][y]
				#check if there are any lines
				if(current != nil)
					if(current == gameBoard.grid[x][y+1] &&
						current == gameBoard.grid[x][y+2] &&
						current == gameBoard.grid[x][y+3])
						gameBoard.endGame = true;
						return current;
					end
					if (x < gameBoard.colSize - 3)
						if(
							current == gameBoard.grid[x+1][y] &&
							current == gameBoard.grid[x+2][y] &&
							current == gameBoard.grid[x+3][y])
							gameBoard.endGame = true;
							return current;
						end
						if(current == gameBoard.grid[x+1][y+1] &&
							current == gameBoard.grid[x+2][y+2] &&
							current == gameBoard.grid[x+3][y+3])
							gameBoard.endGame = true;
							return current;
						end
						
						# Check lower diagonal
						if(y >= 3)
							if(current == gameBoard.grid[x+1][y-1] &&
								current == gameBoard.grid[x+2][y-2] &&
								current == gameBoard.grid[x+3][y-3])
								gameBoard.endGame = true;
								return current;
							end
						end
					end
				else
					anyOpenSpace = true
				end
			end
		end
		if(!anyOpenSpace)
			gameBoard.endGame = true;
			return "draw"
		end
	end
end