module GamesHelper
  include ApplicationHelper

  def who_wins?(player_hand, bot_hand, player_turn, bot_turn) 
    if (player_hand > bot_hand)
      message = "Player wins!"
    elsif (player_hand < bot_hand)
      message ="Bot wins!" 
    elsif player_hand == bot_hand
      message = "Friendship wins!"
    end
    if fold? player_turn
      message ="Bot wins!"     
    end  
    if fold? bot_turn
      message ="Player wins!" 
    end
    message
  end

  def set_session_values
    session[:deck] = Deck.new
    session[:player_cards] = []
    session[:flop] = []
    session[:turn] = []
    session[:river] = []
    session[:player_turn] = ""
    session[:bot] = Bot.new
  end
end
