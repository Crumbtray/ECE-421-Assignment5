require 'rubygems'
require './connect_four_game'
require './dumb_ai'
require './win_checker_normal'
require './win_checker_toot'
require 'gtk2'

class ConnectFourUI
  attr :glade

  def initialize
    @gameInstance = ConnectFourGame.new(WinCheckerNormal, self, DumbAI.new)
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
        dialog = Gtk::Dialog.new("Attention", @window1)
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

        @window1 = @builder.get_object("window1")
        @window1.signal_connect("destroy") {
          Gtk.main_quit
        }
        @window1.show()
        @setupWindow.hide()
      end
    }

    @setupWindow.show()

  end
end

ConnectFourUI.new