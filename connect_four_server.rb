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
	attr_reader :roomId, :numPlayers

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
			raise ArgumentError, "Invalid operation: You cannot restart a game that is on-going." unless @game.nil?
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
end

class ConnectFourServer
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

	def connect(player, roomId)
		@gameRooms[roomId].connect(player)
	end

	def startGame(player, roomId, gameType)
		@gameRooms[roomId].startGame(player, gameType)
	end

	def getGameState(roomId)
		@gameRooms[roomId].getGameState
	end

	def getCurrentPlayer(roomId)
		@gameRooms[roomId].getGameState
	end

	def move(roomId, player, column)
		@gameRooms[roomId].move(player, column)
	end
end

server = XMLRPC::Server.new(port, ENV['HOSTNAME'])

server.add_handler("ConnectFourGameServer",  ConnectFourServer.new)

server.serve
