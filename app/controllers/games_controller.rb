class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_owner, :except => [:index, :new, :create]
  before_filter :game_started?, :only => [:check, :raise_bet, :fold, :call]
  before_filter :initialize_session, :only => [:show]


  def initialize_session
    if !@game.started? && !@game.ended? 
      set_session_values
    end 
  end

  def repeated_start
    redirect_to @game, notice: "Game is already started" if @game.started?
  end

  def game_started?
    redirect_to @game, notice: "Click 'Start game' first." unless @game.started?
  end

  def check_owner
    @game = Game.find(params[:id])
    redirect_to games_path, notice: "This is not your game!" unless current_user.games.to_a.include? @game
  end
  include GamesHelper

  def start
    @game = Game.find(params[:id])
    @game.started = true
    @game.ended = false
    @game.status = "started"
    @game.take_bets(current_user)
    #@game.player_turn = [true, false].sample
    @game.player_turn = true
    session[:bot] = Bot.new
    @game.save
    set_session_values
    session[:deck].deal
    session[:player_cards].push session[:deck].deal
    session[:bot].cards.push session[:deck].deal
    session[:player_cards].push session[:deck].deal
    session[:bot].cards.push session[:deck].deal
    flash[:notice] = 'You started game.'
    redirect_to @game
  end

  def index
    @games = current_user.games
  end

  def show
    
    @game = Game.find(params[:id])
    if session[:bot].turn == "raise"
      flash[:notice] = "Bot bet #{session[:bot].bet}"
    end
    @player_hand = PokerHand.new(session[:player_cards] + session[:flop] +  session[:turn] + session[:river])
    @bot_hand = PokerHand.new(session[:bot].cards + session[:flop] +  session[:turn] + session[:river])
    if @game.ended?
      @game.started = false
      flash.now[:notice] = who_wins?(@player_hand, @bot_hand, session[:player_turn], session[:bot].turn)
      @player_hand = @bot_hand = PokerHand.new
      if flash[:notice] == "Player wins!"
        current_user.credits += @game.pot
        current_user.wins += 1
        if @game.aggressive?
          @game.aggressive_losts += 1
        else
          @game.carefull_losts += 1
        end 
      elsif flash[:notice] == "Bot wins!"
        if @game.aggressive?
          @game.aggressive_bank += @game.pot
          @game.aggressive_wins += 1
        else
          @game.carefull_bank += @game.pot
          @game.carefull_wins += 1
        end  
        current_user.losts += 1
      elsif flash[:notice] == "Friendship wins!"
        current_user.credits += @game.pot/2 
        if @game.aggressive?
          @game.aggressive_bank += @game.pot/2
        else
          @game.carefull_bank += @game.pot/2
        end  
      end
      session = []     
      current_user.save  
      warn current_user.credits.inspect
      @game.ended = false
      @game.pot = 0
      @game.save      
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy
    flash[:notice] = "Game is successfully deleted!"
    redirect_to root_path
  end 

  def new
    @game = Game.new
  end

  def create
    @game = current_user.games.new(params[:game])
    if @game.save
      redirect_to @game
      flash[:success] = "Game is successfully created!"
    else
      render :new
    end
  end

  def check
    @game = Game.find(params[:id])
    if !@game.ended?
      check_turn(@game)
      session[:bot].make_turn(@game, session[:player_turn], 0, session[:flop])
      @game.set_status
      @game.save
      give_cardz(@game)
      flash[:notice] = @game.status  
    else
      flash[:notice] = "Game is ended. Start new game."
    end
    redirect_to @game
  end

  def raise_bet
    @game = Game.find(params[:id])
    if !@game.ended?
      session[:player_turn] = "raise"
      bet = raise_turn(@game)
      session[:floop] = [] if session[:floop].nil?
      session[:bot].make_turn(@game, session[:player_turn], bet, session[:floop] + session[:river] + session[:turn])
      if session[:bot].turn == "fold"
        bot_fold_turn(@game)       
      end
    else
      flash[:notice] = "Game is ended. Start new game."
    end
    @game.set_status
    give_cardz(@game)
    flash[:notice] = @game.status
    @game.save
    redirect_to @game
  end

  def fold
    @game = Game.find(params[:id])
    if !@game.ended?
      player_fold_turn(@game)
      @game.save
    else
      flash[:notice] = "Game is ended. Start new game."
    end
    redirect_to @game
  end

  def call
    @game = Game.find(params[:id])
    if !@game.ended?
      call_turn(@game)
      @game.save
    else
      flash[:notice] = "Game is ended. Start new game."
    end
    flash[:notice] = @game.status
    redirect_to @game
  end

  def last
    current_user.games.order(:created_at)
  end

  private

  def give_cardz(game)
    if game.flop?
      session[:deck].deal
      3.times { session[:flop].push session[:deck].deal }
    elsif game.turn?
      session[:deck].deal
      session[:turn].push session[:deck].deal
    elsif game.river?
      session[:deck].deal
      session[:river].push session[:deck].deal
    end
  end

  def bot_turn(game, bet = nil)
    # session[:bot].make_turn(game, bet, session[:player_turn])
    if check?(session[:player_turn])
      session[:bot_turn] = "check"
    elsif raise?(session[:player_turn])
      session[:bot_turn] = "call"
      game.pot += bet.to_i
    end
    game.bot_turn = false
    game.player_turn = true
  end

  def raise_turn(game)
    game.bot_turn = true
    session[:player_turn] = "raise"
    game.pot += params[:raise_bet].to_i
    params[:raise_bet]
  end

  def check_turn(game)
      game.player_turn = !game.player_turn
      game.bot_turn = true
      session[:player_turn] = "check"
  end

  def player_fold_turn(game)
      session[:player_turn] = "fold"
      game.status = "Player fold"
      common_fold_things(game)
  end

  def bot_fold_turn(game)
    game.status = "Bot fold"
    common_fold_things(game)
  end

  def check_game_status
    @game = Game.find(params[:id])
    if @game.pending?
      flash[:notice] = "You should start game first."
    end
    redirect_to :back
  end

  def call_turn(game)
    game.set_status
    give_cardz(game)
    current_user.credits -= session[:bot].bet
    current_user.save
    game.pot += session[:bot].bet
    session[:player_turn] = "call"
    session[:bot].turn = "raise called"
  end


  def common_fold_things(game)
      game.ended = true
      game.started = false
      game.flop = false
      game.river = false
      game.turn = false
  end 


end