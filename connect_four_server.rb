#!/usr/bin/env ruby
require "./connect_four_game_board"
require "./connect_four_game"
require './win_checker_normal'
require './win_checker_toot'
require "xmlrpc/server"

#
# Novemver 2013 - Verified working on ports 50500 to 50550, its suggested
# to work only within ports 50500-50550
#
port = 50500

class ConnectFourGameRoom
	attr_reader :roomId, :numPlayers, :player1, :player2

	def initialize(roomId)
		@roomId = roomId
		@numPlayers = 0
	end

	def connect(player)
		if @numPlayers == 0
			@player1 = player
			@numPlayers = 1
			#puts "Connect NumPlayers: #{@numPlayers}"
		elsif @numPlayers == 1
			@player2 = player
			@numPlayers = 2
		else
			raise ArgumentError, "Unable to join.  There are already two players in this game."
		end
	end

	def startGame(player, gameType)
		puts "NumPlayers: #{@numPlayers}"
		# Pre Conditions
		begin
			raise ArgumentError, "Invalid Game Type." unless (gameType == "Normal" || gameType == "TOOT")
		end

		begin
			raise ArgumentError, "Invalid operation: You cannot restart a game that is on-going." unless @game.nil? || @game.gameBoard.endGame
		end

		begin
			raise ArgumentError, "You require two players." unless @numPlayers == 2
		end

		begin
			raise ArgumentError, "Only player 1 can set the game." unless player == @player1
		end
		# End Pre Conditions

		if(gameType == "Normal")
			@game = ConnectFourGame.new(WinCheckerNormal, @player1, @player2)
		else
			@game = ConnectFourGame.new(WinCheckerToot, @player1, @player2)
		end

		return "OK"
	end

	def getGameState
		puts "GameState: #{@game.gameBoard.grid}"
		return @game.gameBoard.grid
	end

	def getCurrentPlayer
		return @game.gameBoard.currentPlayer
	end

	def move(player, column)
		@game.move(player, column)
		return "OK"
	end

	def saveGame

	end

	def loadGame(gameId)

	end

	def getLeaderBoard()

	end

	def disconnect(player)
		# End the game
		if(!@game.nil?)
			@game.gameBoard.endGame = true
		end
		# Whoever remains is the winner
		# Record the stats
		# Clean out the room.
		@numPlayers = @numPlayers - 1
		return "You just exited the game."
	end

	def getGameActive
		if(@game.nil?)
			return false
		else
			return !@game.gameBoard.endGame
		end
	end

	def getWinner
		return @game.gameBoard.winner
	end
end

class ConnectFourServer
	attr_reader :gameRooms

	def initialize
		@gameRooms = Array.new
		for i in 1..10
			@gameRooms.push(ConnectFourGameRoom.new(i))
		end
	end

	def getServers
		returnVal = Array.new
		@gameRooms.each {|room|
			returnVal.push(room.numPlayers)
		}
		return returnVal
	end

	def connect(roomId, player)
		@gameRooms[roomId - 1].connect(player)
	end

	def startGame(roomId, player, gameType)
		@gameRooms[roomId - 1].startGame(player, gameType)
	end

	def getGameState(roomId)
		@gameRooms[roomId - 1].getGameState
	end

	def getCurrentPlayer(roomId)
		@gameRooms[roomId - 1].getGameState
	end

	def move(roomId, player, column)
		@gameRooms[roomId - 1].move(player, column)
	end

	def getRoomPlayer1(roomId)
		@gameRooms[roomId - 1].player1
	end

	def getRoomPlayer2(roomId)
		@gameRooms[roomId - 1].player2
	end

	def getRoomNumPlayers(roomId)
		@gameRooms[roomId - 1].numPlayers
	end

	def disconnect(roomId, player)
		@gameRooms[roomId - 1].disconnect(player)
	end

	def getRoomGameActive(roomId)
		@gameRooms[roomId - 1].getGameActive
	end

	def getRoomWinner(roomId)
		@gameRooms[roomId - 1].getWinner
	end
end

server = XMLRPC::Server.new(port, ENV['HOSTNAME'])

server.add_handler("ConnectFourGameServer",  ConnectFourServer.new)

server.serve
