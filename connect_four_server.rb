#!/usr/bin/env ruby
require "./connect_four_game_board"
require "./connect_four_game"
require './win_checker_normal'
require './win_checker_toot'
require "xmlrpc/server"
require './connect_four_database'

#
# Novemver 2013 - Verified working on ports 50500 to 50550, its suggested
# to work only within ports 50500-50550
#
port = 50500

class ConnectFourGameRoom
	attr_reader :roomId, :numPlayers, :player1, :player2, :gameType

	def initialize(roomId)
		@db = ConnectFourDatabase.new
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
			@gameType = "Normal"
		else
			@game = ConnectFourGame.new(WinCheckerToot, @player1, @player2)
			@gameType = "TOOT"
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
		if(@game.gameBoard.endGame)
			if(@game.gameBoard.winner == "draw")
				@db.addTie(@game.player1)
				@db.addTie(@game.player2)
			elsif(@game.gameBoard.winner == @game.player1)
				@db.addWin(@game.Player1)
				@db.addLoss(@game.Player2)
			else
				@db.addWin(@game.Player2)
				@db.addLoss(@game.Player1)
			end
		end
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

		@db = ConnectFourDatabase.new
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

	def getRoomGameType(roomId)
		@gameRooms[roomId - 1].gameType
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

	def saveGame(player1, player2, gameType)
		#Save the game to the db
		@db.saveGame(player1, player2, gameType)
	end

	def loadGame(player)
		#Load game from db
		player2, gameType = @db.loadGame(player)
		#Scan current rooms to see if any of them match (also check if the room is free in case we need it)
		freeRoomId = -1
		@gameRooms.each do |room|
			if((room.player1 == player) and (room.gameType == gameType) and (room.player2.nil?))
				#Room matches, add the player to the room
				room.connect(player)
				#Return the room id
				return room.roomId
			elsif !(room.getGameActive)
				freeRoomId = room.roomId
			end
		end
		
		#No matches found, add player to room and initialize game
		if(freeRoomId != -1)
			@gameRooms[freeRoomId - 1].startGame(player, gameType)
		end
		return freeRoomId
	end

	def getLeaderBoard()
		return @db.getLeaderBoard
	end
end

server = XMLRPC::Server.new(port, ENV['HOSTNAME'])

server.add_handler("ConnectFourGameServer",  ConnectFourServer.new)

server.serve
