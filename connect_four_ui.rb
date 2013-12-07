require 'rubygems'
require './connect_four_client'
require 'gtk2'

class ConnectFourUI
  attr :glade

  def initialize
    Gtk.init
    @builder = Gtk::Builder::new
    @builder.add_from_file("ConnectFourUI.glade")
    @builder.connect_signals{ |handler| method(handler) }  # (I don't have any handlers yet, but I will have eventually)

    setup

    Gtk.main()
  end

  def setup
    @setupWindow = @builder.get_object("setup_window")
    @setupWindow.signal_connect("destroy") {
      Gtk.main_quit
    }

    playerName = @builder.get_object("player_name")
    setupExitButton = @builder.get_object("setup_exit")
    setupExitButton.signal_connect("clicked") {
      Gtk.main_quit
    }
    setupStartButton = @builder.get_object("setup_start")
    setupStartButton.signal_connect("clicked") {
      if(playerName.text.empty?)
        dialog = Gtk::Dialog.new("Attention", @setupWindow)
        dialog.signal_connect('response') {dialog.destroy}
        dialog.vbox.add(Gtk::Label.new("You must have a name."))
        dialog.show_all
      else
        @playerName = playerName.text
        ghosty = @builder.get_object("ghosty")
        if(ghosty.active?)
          @playerToken = "ghost.png"
          @enemyToken = "bunny.png"
        else
          @playerToken = "bunny.png"
          @enemyToken = "ghost.png"
        end
        @client = ConnectFourClient.new(@playerName)
        @window1 = @builder.get_object("RoomSelectWindow")
        @window1.signal_connect("destroy") {
          Gtk.main_quit
        }
        begin
          setupGameRoomsWindow
          @window1.show()
          @setupWindow.hide()
        rescue Exception => e
          dialog = Gtk::Dialog.new("Attention", @setupWindow)
          dialog.signal_connect('response') {dialog.destroy}
          dialog.vbox.add(Gtk::Label.new("Looks like the server is down."))
          dialog.show_all
        end

      end
    }

    @setupWindow.show()
  end

  def setupGameRoomsWindow
    refreshButton = @builder.get_object("refresh_server")
    refreshButton.signal_connect("clicked") {
      refreshGameRooms
    }
    refreshGameRooms

    joinButton = @builder.get_object("join_button")
    joinButton.signal_connect("clicked") {
      tryJoinRoom
    }

    leaderBoardsButton = @builder.get_object("leaderBoards")
    leaderBoardsButton.signal_connect("clicked") {
      @leaderBoardWindow = @builder.get_object("leaderBoardWindow")

      labelText = "LeaderBoards\nName:\t\tWin:\t\tLose\t\tTie:\n"

      leaderboardInfo = @client.gameServer.getLeaderBoard
      leaderboardInfo.each {|row|
        row.each {|entry|
          labelText.concat("#{entry}\t\t\t")
        }
        labelText.concat("\n")
      }

      leaderBoardsLabel = @builder.get_object("leaderBoardText")
      leaderBoardsLabel.text=labelText

      leaderBoardCloseButton = @builder.get_object("closeLeaderboard")
      puts leaderBoardCloseButton
      leaderBoardCloseButton.signal_connect("clicked") {
        @leaderBoardWindow.hide
      }

      @leaderBoardWindow.show_all

    }

    loadButton = @builder.get_object("loadGame")
    loadButton.signal_connect("clicked") {
      roomId = @client.gameServer.loadGame(@playerName)
      if(roomId == -1)
        dialog = Gtk::Dialog.new("Attention", @setupWindow)
        dialog.signal_connect('response') {dialog.destroy}
        dialog.vbox.add(Gtk::Label.new("You have no saved games."))
        dialog.show_all
      else
        @roomNumber = roomId
        @window1.hide()
        @lobbyWindow = @builder.get_object("lobby_window")
        @lobbyWindow.signal_connect("destroy") {
            puts @client.gameServer.disconnect(@roomNumber, @playerName)
            Gtk.main_quit
        }
        setupLobbyRoom
        @lobbyWindow.show_all
      end
    }

    @roomNumberText = @builder.get_object("roomNumber")

  end

  def refreshGameRooms
    puts "Getting lobby information"
    @roomInfo = @client.gameServer.getServers
    for i in 17..26
      label = @builder.get_object("label" + i.to_s)
      label.text="#{@roomInfo[i - 17]} / 2"
    end
  end

  def tryJoinRoom
    refreshGameRooms
    if(@roomNumberText.text.empty?)
        dialog = Gtk::Dialog.new("Attention", @setupWindow)
        dialog.signal_connect('response') {dialog.destroy}
        dialog.vbox.add(Gtk::Label.new("You must select a room."))
        dialog.show_all
    elsif (@roomNumberText.text.to_i > 10 || @roomNumberText.text.to_i < 1)
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("Invalid Room number."))
      dialog.show_all
    elsif (@roomInfo[@roomNumberText.text.to_i - 1] == 2)
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("Room is full.  Please select another room."))
      dialog.show_all
    elsif (@roomInfo[@roomNumberText.text.to_i - 1] == 1 && @client.gameServer.getRoomPlayer1(@roomNumberText.text.to_i) == @playerName)
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("Someone else is in here with your name!"))
      dialog.show_all
    else
      @roomNumber = @roomNumberText.text.to_i
      @client.gameServer.connect(@roomNumber, @playerName)
      @window1.hide()
      @lobbyWindow = @builder.get_object("lobby_window")
      @lobbyWindow.signal_connect("destroy") {
          puts @client.gameServer.disconnect(@roomNumber, @playerName)
          Gtk.main_quit
      }
      setupLobbyRoom
      @lobbyWindow.show_all
    end
  end

  def setupLobbyRoom
    lobbyRefreshButton = @builder.get_object("lobbyRefresh")
    lobbyRefreshButton.signal_connect("clicked") {
      refreshLobby
    }
    refreshLobby

    startGameButton = @builder.get_object("lobby_start_game")


    if(@client.gameServer.getRoomNumPlayers(@roomNumber) == 2)
      # You are the second player to enter the room.  You do not get to choose the game.
      buttons = @builder.get_object("hbuttonbox2")
      buttons.sensitive=false
    end

    startGameButton.signal_connect("clicked") {
      if(@client.gameServer.getRoomPlayer1(@roomNumber) == @playerName)
        if(@client.gameServer.getRoomNumPlayers(@roomNumber) == 2)

          #I'm player 1, so I get to dictate the game.
          normalGameTypeRadio = @builder.get_object("lobby_normal")
          if(normalGameTypeRadio.active?)
            startOnlineGame("Normal")
          else
            startOnlineGame("Toot")
          end

          @lobbyWindow.hide
          @online_window = @builder.get_object("online_window")
          @online_window.signal_connect("destroy") {
            puts @client.gameServer.disconnect(@roomNumber, @playerName)
            Gtk.main_quit
          }
          setupOnlineGameBoard
          @online_window.show_all
        else
          dialog = Gtk::Dialog.new("Attention", @setupWindow)
          dialog.signal_connect('response') {dialog.destroy}
          dialog.vbox.add(Gtk::Label.new("Can't start the game with only 1 person!"))
          dialog.show_all
        end
      else
        # I'm player 2, so I have to keep checking until I can join the game.
        if(!@client.gameServer.getRoomGameActive(@roomNumber))
          dialog = Gtk::Dialog.new("Attention", @setupWindow)
          dialog.signal_connect('response') {dialog.destroy}
          dialog.vbox.add(Gtk::Label.new("Waiting on Player 1 to decide on the game."))
          dialog.show_all
        else
          @lobbyWindow.hide
          @online_window = @builder.get_object("online_window")
          @online_window.signal_connect("destroy") {
            puts @client.gameServer.disconnect(@roomNumber, @playerName)
            Gtk.main_quit
          }
          setupOnlineGameBoard
          @online_window.show_all
        end
      end
    }
  end

  def refreshLobby
    puts "Refreshing lobby..."
    lobbyp1label = @builder.get_object("lobby_p1_label")
    lobbyp2label = @builder.get_object("lobby_p2_label")
    if(@client.gameServer.getRoomNumPlayers(@roomNumber) == 1)
      lobbyp1label.text= @playerName
      lobbyp2label.text="Waiting for player 2..."
    else
      lobbyp1label.text=@client.gameServer.getRoomPlayer1(@roomNumber)
      lobbyp2label.text=@client.gameServer.getRoomPlayer2(@roomNumber)
    end
  end

  def startOnlineGame(gameType)
    if(@client.gameServer.getRoomNumPlayers(@roomNumber) != 2)
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("You require 2 players to play."))
      dialog.show_all
    else
      @client.gameServer.startGame(@roomNumber, @playerName, gameType)
    end

  end

  def setupOnlineGameBoard
    #Setup the Save Game Button.
    saveGameButton = @builder.get_object("save_game")
    saveGameButton.signal_connect("clicked") {
      @client.gameServer.saveGame(@client.gameServer.getRoomPlayer1(@roomNumber), @client.gameServer.getRoomPlayer2(@roomNumber),@client.gameServer.getRoomGameType(@roomNumber))
    }

    # Setup the label.
    gameName = @builder.get_object("Game_Label")
    gameName.text="Room #{@roomNumber}"

    # Setup all the buttons.  Gotta do it manually, one at a time.
    button1 = @builder.get_object("gameButton1")
    button1.signal_connect("clicked") {
      tryMove(1)
    }

    button2 = @builder.get_object("gameButton2")
    button2.signal_connect("clicked") {
      tryMove(2)
    }

    button3 = @builder.get_object("gameButton3")
    button3.signal_connect("clicked") {
      tryMove(3)
    }

    button4 = @builder.get_object("gameButton4")
    button4.signal_connect("clicked") {
      tryMove(4)
    }

    button5 = @builder.get_object("gameButton5")
    button5.signal_connect("clicked") {
      tryMove(5)
    }

    button6 = @builder.get_object("gameButton6")
    button6.signal_connect("clicked") {
      tryMove(6)
    }

    button7 = @builder.get_object("gameButton7")
    button7.signal_connect("clicked") {
      tryMove(7)
    }

    GLib::Timeout.add(500) {
      updateBoard
    }
  end

  def tryMove(column)
    begin
      @client.gameServer.move(@roomNumber, @playerName, column)
      updateBoard
    rescue Exception => e
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("Please wait for your turn!"))
      dialog.show_all
    end
  end

  def updateBoard
    board = @client.gameServer.getGameState(@roomNumber)
    board.each_with_index {|column, colIndex|
      column.each_with_index {|row, rowIndex|
        if(row == @playerName)
          image = @builder.get_object("gameImage#{colIndex}#{rowIndex}")
          image.set_file(@playerToken)
        else
          image = @builder.get_object("gameImage#{colIndex}#{rowIndex}")
          image.set_file(@enemyToken)
        end
      }
    }
    # Check if someone won
    result = @client.gameServer.getRoomGameActive(@roomNumber)
    if (!result)
      winner = @client.gameServer.getRoomWinner(@roomNumber)
      dialog = Gtk::Dialog.new("Winner", @online_window)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("#{winner} has won the game!  Please exit now."))
      dialog.show_all
      return false
    end

    return true
  end

end

ConnectFourUI.new