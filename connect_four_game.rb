require 'test/unit/assertions.rb'
require './connect_four_game_board'
require './win_checker_normal'
include Test::Unit::Assertions

class ConnectFourGame
 
	attr_reader :rows, :columns, :gameBoard, :player1, :player2, :winner
	attr_accessor :winChecker
	
	def initialize(winChecker, player1, player2)
		# Game Type is either Normal, or TOOT (OTTO)
		@player1 = player1
		@player2 = player2
		@winChecker = winChecker
		@gameBoard = ConnectFourGameBoard.new(6, 7, player1, player2)
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

		@gameBoard.add(player, column)
	    @winChecker.checkWinCondition(@gameBoard)


	    #Post Conditions
	    assert(@gameBoard.grid[column - 1].size >= beforeCount)
	    #End Post Conditions
	end
end