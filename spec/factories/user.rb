require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "test+#{i}@mail.ru" }

    password '123456'
    password_confirmation '123456'
    
  end

end
