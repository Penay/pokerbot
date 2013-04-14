require 'factory_girl'

FactoryGirl.define do


	factory :game do
		sequence(:name) { |i| "test_game_#{i}" }
	end

end