FactoryGirl.define do
  factory :chapter do
    sequence(:title) { |n| "Chapter #{n}" }
    text 'Some awesome text for great test'
  end
end
