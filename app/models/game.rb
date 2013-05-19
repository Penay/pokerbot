class Game < ActiveRecord::Base
  has_one :deck
  GAME_BETS = (1..100)

  attr_accessible :name, :pot, :blind, :waiting, :bot_type
  belongs_to :user

  # validates :name, presence: true
  
  def set_status
    if self.started? && !self.flop? && !self.turn? && !self.river? && !self.ended?
      self.status = "flop"
      self.flop = true
    elsif self.flop? && self.started?
      self.status = "turn"
      self.flop = false
      self.turn = true
    elsif self.turn? && self.started?
      self.status = "river"
      self.turn = false
      self.river = true
    elsif self.river? && self.started?
      self.status = "ended"
      self.river = false
      self.ended = true
      self.started = false
    end
  end


  def take_bets(user)
    self.pot += self.blind*3
    user.credits -= self.blind
    user.save
  end

  def end_game
    self.pot = 0
    self.save
  end

  def aggressive? 
    self.bot_type == 'aggressive' ? true : false
  end

  def carefull? 
    self.bot_type == 'carefull' ? true : false
  end


end
