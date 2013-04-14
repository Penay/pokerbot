module GamesHelper
  def check?(turn)
    turn == "check" ? true : false
  end

  def fold?(turn)
    turn == "fold" ? true : false
  end

  def raise?(turn)
    turn == "raise" ? true : false
  end

  def who_wins?(player_hand, bot_hand)
    if player_hand > bot_hand
      message = "Player wins!"
      current_user.wins += 1
    elsif player_hand < bot_hand
      message ="Bot wins!"
      current_user.losts += 1
    elsif player_hand == bot_hand
      message = "Friendship wins!"
    end
    current_user.save
    message
  end
end
