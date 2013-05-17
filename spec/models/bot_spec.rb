require 'spec_helper'

describe Bot do
	let(:bot) { Bot.new }
  describe "check pre floop" do
  	it "returns 'raise big' if it is a high pair" do
  		card1 = card2 ="A"
  		bot.check_pre_floop(card1, card2).should == "big_raise"
  	end
  end
end
