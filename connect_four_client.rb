require "xmlrpc/client"

class ConnectFourClient

	def initialize(player)
		@player = player
		server = XMLRPC::Client.new("localhost", "/RPC2", 50500);
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

	def getLeaderBoard

	end
end

client = ConnectFourClient.new("me")

client2 = ConnectFourClient.new("me2")

client.startGame("Normal")

client.move(1)

puts client.getGameState.to_s

client.move(1)