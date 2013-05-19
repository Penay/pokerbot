class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  def after_sign_in_path_for(resource)
    session[:bot] = []
    session[:player_cards] = []
    session[:player_turn] = []
    session[:flop] = []
    session[:turn] = []
    session[:river] = []
    new_game_path
  end


  def after_sign_out_path_for(resource_or_scope)
    session[:bot] = []
    session[:player_cards] = []
    session[:player_turn] = []
    session[:flop] = []
    session[:turn] = []
    session[:river] = []
    new_user_session_path
  end


end
