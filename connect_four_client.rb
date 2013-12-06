require "xmlrpc/client"

class ConnectFourClient

	def initialize(player, port)
		@player = player
		server = XMLRPC::Client.new("localhost", "/RPC2", port);
		@gameServer = server.proxy("ConnectFourGameServer")
		@gameServer.connect(player)
	end

	def startGame(gameType)
		@gameServer.startGame(gameType)
	end

	def move(column)
		@gameServer.move(@player, column)
	end

	def getGameState
		return @gameServer.getGameState
	end

	def getCurrentPlayer
		return @gameServer.getCurrentPlayer
	end

	def getLeaderBoard

	end
end

client = ConnectFourClient.new("me", 50500)

client2 = ConnectFourClient.new("me2", 50501)

client.startGame("Normal")

client.move(1)

puts client.getGameState.to_s

puts client.getCurrentPlayer