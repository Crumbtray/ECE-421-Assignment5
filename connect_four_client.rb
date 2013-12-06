require "xmlrpc/client"

class ConnectFourClient

	attr_reader :gameServer

	def initialize(player)
		@player = player
		server = XMLRPC::Client.new("localhost", "/RPC2", 50500);
		@gameServer = server.proxy("ConnectFourGameServer")
	end
end