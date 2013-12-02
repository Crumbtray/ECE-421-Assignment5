require 'test/unit/assertions.rb'
require './connect_four_game_board'
require './win_checker_normal'
include Test::Unit::Assertions

class ConnectFourGame
 
	attr_reader :rows, :columns, :gameBoard, :player1, :player2
	attr_accessor :winChecker
	
	def initialize(winChecker, player1, ai)
		# Game Type is either Normal, or TOOT (OTTO)
		@player1 = player1
		@player2 = ai
		@winChecker = winChecker
		@gameBoard = ConnectFourGameBoard.new(6, 7, player1, ai)
	end

	def move(player, column)
	    #Pre Conditions
		begin
			raise ArgumentError, "Game is over.  Please start a new one." unless @gameBoard.endGame == false
		end

		begin
			raise ArgumentError, "Column is full.  Please choose another column." unless @gameBoard.grid[column - 1].size < @gameBoard.rowSize
		end
	    
	    #End PreConditions
		
		beforeCount = @gameBoard.grid[column - 1].size

		returnVal = @gameBoard.add(player, column)
	    
	    #Post Conditions
	    assert(@gameBoard.grid[column - 1].size >= beforeCount)
	    #End Post Conditions
		
		player1.updateGrid(returnVal, player)
	end

	def endTurn()
		potentialWinner = @winChecker.checkWinCondition(@gameBoard)
	    if(@gameBoard.endGame == true)
	    	@player1.endGame(potentialWinner)
	    else
	    	@player2.makeMove(self)
	    	potentialWinner = @winChecker.checkWinCondition(@gameBoard)
	    	if(@gameBoard.endGame == true)
	    		@player1.endGame(potentialWinner)
	    	end
	    end
	end
end