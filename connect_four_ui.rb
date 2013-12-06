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
    puts setupExitButton
    setupExitButton.signal_connect("clicked") {
      puts "CLICKED EXIT"
      Gtk.main_quit
    }
    setupStartButton = @builder.get_object("setup_start")
    puts setupStartButton
    setupStartButton.signal_connect("clicked") {
      if(playerName.text.empty?)
        dialog = Gtk::Dialog.new("Attention", @setupWindow)
        dialog.signal_connect('response') {dialog.destroy}
        dialog.vbox.add(Gtk::Label.new("You must have a name."))
        dialog.show_all
      else
        puts "CLICKED START"
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
        setupGameRoomsWindow

        @window1.show()
        @setupWindow.hide()
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
    puts "Trying to join room #{@roomNumberText.text}"
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
    elsif (@roomInfo[@roomNumberText.text.to_i] == 2)
      dialog = Gtk::Dialog.new("Attention", @setupWindow)
      dialog.signal_connect('response') {dialog.destroy}
      dialog.vbox.add(Gtk::Label.new("Room is full.  Please select another room."))
      dialog.show_all
    else
      @roomNumber = @roomNumberText.text.to_i
      @client.gameServer.connect(@roomNumber, @playerName)
    end
  end




end

ConnectFourUI.new