module GamesHelper
  include ApplicationHelper

  def who_wins?(player_hand, bot_hand, player_turn, bot_turn)
    if (player_hand > bot_hand) | fold?(bot_turn)
      warn "_"*30
      warn "Player wins"
      message = "Player wins!"
    elsif (player_hand < bot_hand) | fold?(player_turn)
      warn "_"*30
      warn "Bot wins"
      message ="Bot wins!" 
    elsif player_hand == bot_hand
      warn "_"*30
      warn "Friendship wins!"
      message = "Friendship wins!"
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
