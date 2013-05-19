class ProfilesController < ApplicationController
  def show
  end

  def statistic
  	@aggressive_bank = Game.sum(:aggressive_bank)
  	@aggressive_wins = Game.sum(:aggressive_wins)
  	@aggressive_losts = Game.sum(:aggressive_losts)
  	@carefull_bank = Game.sum(:carefull_bank)
  	@carefull_wins = Game.sum(:carefull_wins)
  	@carefull_losts = Game.sum(:carefull_losts)
  end
end
