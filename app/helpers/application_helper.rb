module ApplicationHelper 
  def full_title(page_title)
    base_title = "Poker Trainer"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def check?(turn)
    turn == "check" ? true : false
  end

  def fold?(turn)
    turn == "fold" ? true : false
  end

  def raise?(turn)
    turn == "raise" ? true : false
  end

  def call?(turn)
    turn == "call" ? true : false
  end

  def monster?(hand)
    if (PokerHand.new(hand).hand_rating != 'Highest Card') & (PokerHand.new(hand).hand_rating != 'Pair')
      true
    else
      false
    end
  end

  def top_pair?(hand, table_cards)
    if PokerHand.new(hand + table_cards).hand_rating == 'Pair' 
      true if hand.cards_value.include? highest_value(table_cards)
    else
      false
    end
  end

  def over_pair?(hand, table_cards)
    if PokerHand.new(hand).hand_rating == 'Pair' 
      if highest_value(hand) > highest_value(table_cards)
        true 
      end
    else
      false
    end
  end

  # def straigh_draw?(hand, table_cards)
  #   if highest_value(hand) != 14
  #     if ((hand.cards_value.first - 1) == (hand.cards_value.last)) | ((hand.cards_value.first + 1) == (hand.cards_value.last))
  #       if (table_cards.cards_value.include? (smallest_value(hand) - 1)) & (table_cards.cards_value.include? (smallest_value(hand) - 2))
  #         true
  #       end
  #     end 
  #   else
  #     false
  #   end
  # end

  def flash_draw?(hand, table_cards)
    if hand.first.to_s.card_suit == hand.last.to_s.card_suit
      table_cards.each do |table_card|
        if table_card.to_s.card_suit == hand.first.to_s.card_suit
          return true
        else
          return false
        end
      end
    else
      false
    end
  end

  def highest_value(array)
    array.cards_value
    array.max
  end

  def smallest_value(array)
    array.cards_value
    array.min
  end

end

class String
  def card_value
    if self == 'T'
      10
    elsif self == 'J'
      11
    elsif self == 'Q'
      12
    elsif self == 'K'
      13
    elsif self == 'A'
      14
    else
      self.to_i
    end
  end

  def card_suit
    if self == 'c'
      0 
    elsif self == 'd'
      1 
    elsif self == 'h'
      2
    elsif self == 's' 
      3
    end
  end

end

class Array
  def cards_value
    self.map(&:to_s).map(&:first).map(&:card_value)
  end

  def cards_card_suit
    self.map(&:to_s).map(&:last).map(&:card_suit)
  end
end
