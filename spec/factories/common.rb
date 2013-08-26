FactoryGirl.define do
  sequence(:name) {|n| "name-#{n}" }
  sequence(:surname) {|n| "surname-#{n}" }
  sequence(:email) {|n| "email-#{n}@example.com" }
end
