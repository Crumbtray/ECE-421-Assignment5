#!/usr/bin/env ruby
require "./connect_four_game_board"
require "./connect_four_game"
require './win_checker_normal'
require './win_checker_toot'
require "xmlrpc/server"

port = 50500
#
# Novemver 2013 - Verified working on ports 50500 to 50550, its suggested
# to work only within ports 50500-50550
#

class ConnectFourGameServer

	def initialize
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

	def startGame(gameType)
		puts "NumPlayers: #{@numPlayers}"
		# Pre Conditions
		begin
			raise ArgumentError, "Invalid Game Type." unless (gameType == "Normal" || gameType == "TOOT")
		end

		begin
			raise ArgumentError, "You require two players." unless @numPlayers == 2
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

	def move(player, column)
		puts "Trying to move.."
		@game.move(player, column)
		puts "Finished moving."
		return "OK"
	end

	def saveGame

	end

	def loadGame(gameId)

	end

	def getLeaderBoard()

	end
end

server = XMLRPC::Server.new(port, ENV['HOSTNAME'])

server.add_handler("ConnectFourGameServer",  ConnectFourGameServer.new)

server.serve
