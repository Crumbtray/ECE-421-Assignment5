require 'test/unit/assertions.rb'
include Test::Unit::Assertions

class ConnectFourGameBoard

	attr_reader :grid, :rowSize, :colSize, :currentPlayer, :player1, :player2
	attr_accessor :endGame, :currentPlayer, :grid

	def initialize(rows, columns, player1, player2)
		@grid = Array.new
		@rowSize = rows
		@colSize = columns
		@endGame = false
		@player1 = player1
		@player2 = player2
		@currentPlayer = @player1

		for i in 0..columns - 1
			@grid << Array.new
		end
	end

	def add(player, column)
		# Pre Conditions
		begin
			raise ArgumentError, "ConnectFourGameBoard:: ArgumentError -> invalid column." unless (column > 0 and column <= colSize)
		end

		begin
			raise ArgumentError, "ConnectFourGameBoard:: ArgumentError -> Game is over.  Please start a new one." unless @endGame == false
		end

		begin
			raise ArgumentError, "ConnectFourGameBoard:: ArgumentError -> Not this player's turn." unless @currentPlayer == player
		end

		# Pre Conditions End
		zeroIndexColumn = column - 1
		beforeCol = @grid[zeroIndexColumn].size

		if(@grid[zeroIndexColumn].size < colSize)
			@grid[zeroIndexColumn].push(player)
			returnVal = column + (@grid[zeroIndexColumn].size - 1) * @colSize
			if(@currentPlayer == @player1)
				@currentPlayer = @player2
			else
				@currentPlayer = @player1
			end
			return returnVal
		else
			puts "Invalid move: Column is full."
			return nil
		end

		# Post Conditions
		assert(@grid[zeroIndexColumn].size >= beforeCol)
		# End Post Conditions
	end

	def invariant
		assert(grid.size <= colSize)
		grid.each do |column|
			assert(column.size <= @rowSize)
		end
	end

end