#!/usr/bin/env ruby

require "xmlrpc/server"

port = 50500
#
# Novemver 2013 - Verified working on ports 50500 to 50550, its suggested
# to work only within ports 50500-50550
#

class ConnectFourGameServer
   INTERFACE = XMLRPC::interface("ConnectFourGameServer") {
   #meth 'int add(int, int)', 'Add two numbers', 'add'
   #meth 'int div(int, int)', 'Divide two numbers'
}

	def move()

	end

	def startGame()

	end

	def saveGame()

	end

	def loadGame()

	end

	def getLeaderBoard()

	end
end

server = XMLRPC::Server.new(port, ENV['HOSTNAME'])

server.add_handler(Num::INTERFACE,  ConnectFourGameServer.new)

server.serve
