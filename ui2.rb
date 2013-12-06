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

    @setupWindow = @builder.get_object("setup_window")
    @setupWindow.signal_connect("destroy") {
      Gtk.main_quit
    }

    puts "Registering Exit button...."
    setupExitButton = @builder.get_object("setup_exit")
    puts setupExitButton
    setupExitButton.signal_connect("clicked") {
      puts "CLICKED EXIT"
      Gtk.main_quit
    }
    puts "Registering Start Button...."
    setupStartButton = @builder.get_object("setup_start")
    puts setupStartButton
    setupStartButton.signal_connect("activate") {
      puts "CLICKED START"
      @window1 = @builder.get_object("window1")
      @window1.show()
    }

    @setupWindow.show()
    Gtk.main()
  end

end

ConnectFourUI.new