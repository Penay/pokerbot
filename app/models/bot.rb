class Bot
	include ApplicationHelper
	A_K = ["A", "K"]
	A_Q = ["A","K","Q"]
	Q_J = ["Q", "J"]
	J_T = ["J", "T"]
	NINE_TEN = ["9","T"]
	MONSTER = ['Two pair', 'Three of a kind', 'Straight', 'Flush', 'Full house', 'Four of a kind', 'Straight Flush', 'Royal Flush']

	attr_accessor :turn, :bet
	def initialize(turn = nil, bet = 0, cards = nil, game_status = nil)
		@turn = turn
		@bet = 0
		@cards = []
		@game_status = "started"
	end


	def cards
		@cards
	end


	def make_turn(game, player_turn, player_bet = 0, cards = [])
		warn "_"*30
		warn cards.inspect
		warn "_"*30
		if game.started? && !game.flop? && !game.turn? && !game.river? && !game.ended?
			if check_pre_floop == "big_raise"
				self.bet = (50..100).to_a.sample
				game.pot += self.bet
				self.make_raise
			elsif check_pre_floop == "raise"
				self.make_raise
				self.bet = (1..50).to_a.sample
				game.pot += self.bet 
			elsif check_pre_floop == "fold"
				self.make_fold
			elsif check_pre_floop == "check"
				self.make_check
			end
		elsif game.flop? && game.started?			
			if raise?(player_turn)
				if player_bet.to_i > 74
				 	if monster?(self.cards + cards)
						game.pot += player_bet.to_i
						self.make_call
					else
						self.make_fold
					end
				elsif monster?(self.cards + cards)					
					game.pot += player_bet.to_i
					self.make_call
				else
					self.make_fold
				end
			elsif check?(player_turn) 
				if monster?(self.cards + cards) | over_pair?(self.cards, cards)						
					self.make_raise
					self.bet = (1..50).to_a.sample
					game.pot += self.bet 
				#elsif flash_draw?(self.cards + cards) | straigh_draw?(self.cards + cards) 
					self.make_check
				else
					self.random_check_fold_turn
				end
			end
		elsif game.turn? && game.started?
			if raise?(player_turn)
				if player_bet.to_i > 74
				 	if monster?(self.cards + cards)
						game.pot += player_bet.to_i
						self.make_call
					else
						self.make_fold
					end
				elsif monster?(self.cards + cards)					
					game.pot += player_bet.to_i
					self.make_call
				else
					self.make_fold
				end
			elsif check?(player_turn) 
				if monster?(self.cards + cards) | over_pair?(self.cards, cards)						
					self.make_raise
					self.bet = (1..50).to_a.sample
					game.pot += self.bet 
				#elsif flash_draw?(self.cards + cards) | straigh_draw?(self.cards + cards) 
					self.make_check
				else
					self.random_check_fold_turn
				end
			end
		elsif game.river? && game.started?
			if raise?(player_turn)
				if player_bet.to_i > 74
				 	if monster?(self.cards + cards)
						game.pot += player_bet.to_i
						self.make_call
					else
						self.make_fold
					end
				elsif monster?(self.cards + cards)					
					game.pot += player_bet.to_i
					self.make_call
				else
					self.make_fold
				end
			elsif check?(player_turn) 
				if monster?(self.cards + cards) | over_pair?(self.cards, cards)						
					self.make_raise
					self.bet = (1..50).to_a.sample
					game.pot += self.bet 
				# elsif  flash_draw?(self.cards,cards) fl| straight_draw?(self.cards,cards)
					self.make_check
				else
					self.random_check_fold_turn
				end
			end
		end
	end


	def make_check
		self.turn = "check"
	end

	def make_call
		self.turn = "call"
	end

	def make_raise
		self.turn = "raise"
	end

	def make_fold
		self.turn = "fold"
	end


	def check_pre_floop
		card1_value = self.cards.first.to_s.first
		card2_value = self.cards.last.to_s.first
		
		card1_suit = self.cards.last.to_s.last
		card2_suit = self.cards.last.to_s.last

		if (card1_value == card2_value)
			if A_Q.include? card1_value 
				"big_raise"
			elsif J_T.include? card1_value 
				"raise"
			else
				["check","fold"].sample												
			end
		elsif card1_value == "A"
			if card2_value == "K"
				"big_raise"
			elsif (card2_value == "Q") | ( (card2_value == "J") & (card2_suit == card1_suit)  ) 
				"raise"
			elsif J_T.include? card2_value 
				"call"
			else
				["check","fold"].sample					
			end
		elsif card2_value == "A"
			if card1_value == "K"
				"big_raise"
			elsif (card1_value == "Q") | ( (card1_value == "J") & (card2_suit == card1_suit)  ) 
				"raise"
			elsif J_T.include? card2_value 
				"call"
			else
				["check","fold"].sample						
			end
		elsif card1_value == "K"
			if card2_value == "Q"
				"call"
			else
				["check","fold"].sample						
			end
		elsif card1_value == "K"
			if card2_value == "Q"
				"call"
			else
				["check","fold"].sample			
			end
		else
			["check","fold"].sample				
		end
	end

	def random_check_fold_turn
		self.send([:make_check, :make_fold].sample)
	end


end
