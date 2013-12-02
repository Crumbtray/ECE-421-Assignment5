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
    @builder.add_from_file("connect4.glade")
    @builder.connect_signals{ |handler| method(handler) }  # (I don't have any handlers yet, but I will have eventually)

    @window1 = @builder.get_object("window1")
    @window1.signal_connect( "destroy" ) { Gtk.main_quit }

    table1 = @builder.get_object("table1")

    newNormalGameButton = @builder.get_object("NewNormalGame")
    newNormalGameButton.signal_connect("activate") {
      @gameInstance = ConnectFourGame.new(WinCheckerNormal, self, DumbAI.new)
      @builder.objects.each {|object|
        if(object.is_a? Gtk::Image)
          object.set_file("empty.png")
        end
      }
    }

    newTootGameButton = @builder.get_object("NewTootGame")
    newTootGameButton.signal_connect("activate") {
      @gameInstance = ConnectFourGame.new(WinCheckerToot, self, DumbAI.new)
      @builder.objects.each {|object|
        if(object.is_a? Gtk::Image)
          object.set_file("empty.png")
        end
      }
    }

    menu = @builder.get_object("imagemenuitem5")
    menu.signal_connect( "activate" ) { Gtk.main_quit }

    1.upto(7) { |i| 
        @builder.get_object("button" + i.to_s).signal_connect("clicked") {button_clicked(i)};
    }

    @window1.show()
    Gtk.main()
    
  end

  def button_clicked(tileNumber)  
      begin
        @gameInstance.move(self, tileNumber)
        @gameInstance.endTurn
      rescue Exception => e
        dialog = Gtk::Dialog.new("Attention!", @window1)
        dialog.signal_connect('response') {dialog.destroy}
      
        dialog.vbox.add(Gtk::Label.new(e.message))
        dialog.show_all
      end
  end


  def updateGrid(imageId, player)
    if (player == @gameInstance.gameBoard.player1)
      @builder.get_object("image" + imageId.to_s).set_file("ghost.png")
    else
      @builder.get_object("image" + imageId.to_s).set_file("bunny.png")
    end
  end

  def endGame(winner)
    puts winner
    if(winner == self)
      text = "You win!"
    elsif (winner == "draw")
      text = "Tie game."
    else
      text = "You lose!"
    end
    dialog = Gtk::Dialog.new("Winner", @window1)
    dialog.signal_connect('response') {dialog.destroy}
      
    dialog.vbox.add(Gtk::Label.new(text))
    dialog.show_all
  end

end

ConnectFourUI.new