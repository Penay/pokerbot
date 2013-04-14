class GamesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_owner, :except => [:index, :new, :create]
  #before_filter :game_started?, :only => [:check, :raise_bet, :fold]
  before_filter :repeated_start, :only => [:start]

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

  def turn
    @game = Game.find(params[:id])
  end

  def start
    session[:bot_cards] = []
    session[:player_cards] = []
    session[:floop] = []
    session[:turn] = []
    session[:river] = []
    session[:player_turn] = nil
    session[:bot_turn] = nil
    @game = Game.find(params[:id])
    @game.started = true
    @game.ended = false
    @game.status = "started"
    @game.take_bets(current_user)
    #@game.player_turn = [true, false].sample
    @game.player_turn = true
    @game.bot_turn = !@game.player_turn
    @game.save
    session[:deck] = Deck.new
    session[:player_cards].push session[:deck].deal
    session[:bot_cards].push session[:deck].deal
    session[:player_cards].push session[:deck].deal
    session[:bot_cards].push session[:deck].deal
    flash[:notice] = 'You started game.'
    redirect_to @game
  end

  def index
    @games = current_user.games
  end

  def show
    @game = Game.find(params[:id])
    session[:deck] = Deck.new
    @player_hand = PokerHand.new(session[:player_cards] + session[:floop] +  session[:turn] + session[:river])
    @bot_hand = PokerHand.new(session[:bot_cards] + session[:floop] +  session[:turn] + session[:river])
    if @game.ended?
      flash[:notice] = who_wins?(@player_hand, @bot_hand)
      @game.ended = false
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
    check_turn(@game)
    bot_turn(@game)
    @game.set_status
    @game.save
    if next_poker_turn(@game)
      flash[:notice] = @game.status
    else
      flash[:notice] = "Game is ended. "
    end
    redirect_to @game
  end

  def raise_bet
    @game = Game.find(params[:id])
    raise_turn(@game)
  end

  def fold
    @game = Game.find(params[:id])
    fold_turn(@game)
    if @game.save
      redirect_to @game
    end
  end

  def last
    current_user.games.order(:created_at)
  end

  private
  def bot_turn(game)
    if game.started?
      game.bot_turn = false
      game.player_turn = true
      session[:bot_turn] = "check"
    elsif game.floop?
    elsif game.turn?
    elsif game.river?
    end
  end

  def give_cards(game)
    game.player_cards = game.deck.deal
    game.bot_cards = game.deck.deal
    game.player_cards = game.deck.deal
    game.bot_cards = game.deck.deal
  end

  def raise_turn(game)
    if game.player_turn? && !game.bot_turn
      game.player_turn = !game.player_turn
      game.bot_turn = true
      session[:player_turn] = "raise"

    end
  end

  def check_turn(game)
    if game.player_turn? && !game.bot_turn
      game.player_turn = !game.player_turn
      game.bot_turn = true
      session[:player_turn] = "check"
    end
  end

  def fold_turn(game)
    if game.player_turn? && !game.bot_turn
      game.player_turn = !game.player_turn
      game.bot_turn = true
      session[:player_turn] = "fold"
      game.status = "player fold"
      game.pot = 0
      session[:player_cards] = []
      session[:bot_cards] = []
    end
  end

  def check_game_status
    @game = Game.find(params[:id])
    if @game.pending?
      flash[:notice] = "You should start game first."
    elsif @game.ended?
      who_wins?()
      flash[:notice] = "Game is ended. You can start new game."
    end
    redirect_to :back
  end

  def next_poker_turn(game)
    if game.floop?
      3.times { session[:floop].push session[:deck].deal }
    elsif game.turn?
      session[:turn].push session[:deck].deal
    elsif game.river?
      session[:river].push session[:deck].deal
    elsif game.ended?
      false     
    end
  end


end
