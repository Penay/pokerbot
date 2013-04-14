class Game < ActiveRecord::Base
  has_one :deck

  attr_accessible :name, :pot, :blind, :status, :waiting
  belongs_to :user, :dependent => :destroy
  
  def set_status
    if self.started? && !self.floop? && !self.turn? && !self.river? && !self.ended?
      self.status = "floop"
      self.floop = true
    elsif self.floop? && self.started?
      self.status = "turn"
      self.floop = false
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

end
