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
		if game.aggressive?
			if check?(player_turn)
				random_check_raise(game) 
			elsif raise?(player_turn)
				random_call_raise_fold(game, player_bet)
			end
		else
			if game.started? && !game.flop? && !game.turn? && !game.river? && !game.ended? && !raise?(player_turn)
				if check_pre_floop == "big_raise"
					self.make_raise(game)
				elsif check_pre_floop == "raise"
					self.make_raise(game)
				elsif check_pre_floop == "fold"
					self.make_fold
				elsif check_pre_floop == "check"
					self.make_check
				end
			elsif raise?(player_turn)
				if player_bet.to_i > 74
					if monster?(self.cards + cards) | over_pair?(self.cards, cards)
						self.make_call(player_bet.to_i, game)
						self.make_raise(game)
					else
						random_call_fold(game, player_bet.to_i)
					end
				end
			elsif check?(player_turn) 
				if monster?(self.cards + cards) | over_pair?(self.cards, cards)	
					self.make_raise(game)
				elsif top_pair?(self.cards, cards)
					self.make_check
				else	
					random_check_raise_2(game)
				end							
			end
		end
	end


	def make_check
		self.turn = "check"
	end

	def make_call(bet, game)
		self.turn = "call"
		self.bet = bet
		game.pot += bet
	end

	def make_raise(game)
		self.turn = "raise"
		self.bet = (20..100).to_a.sample
		game.pot += self.bet
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

	def random_check_raise(game)
		random = [1,2,3].sample
		if (random == 1) | (random == 2)
			self.make_raise(game)
		elsif random == 3
			self.make_check
		end
	end

	def random_check_raise_2(game)
		random = [1,2,3].sample
		if (random == 1) | (random == 2)
			self.make_check
		else
			self.make_raise(game)
		end
	end

	def random_call_raise_fold(game, player_bet)
		random = [1,2,3,4].sample
		if (random == 1) | (random == 2)		
			self.make_call(player_bet.to_i, game)
			self.make_raise(game)
		elsif random == 3
			self.make_call(player_bet.to_i, game)
		elsif random == 4
			self.make_fold
		end
	end

	def random_call_fold(game, player_bet)
		random = [1,2].sample
		if random == 1
			self.make_fold
		elsif random == 2
			self.make_call(player_bet, game)
		end
	end


end
