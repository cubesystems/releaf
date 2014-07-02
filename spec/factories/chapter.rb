FactoryGirl.define do
  factory :chapter do
    sequence(:title) { |n| "Chapter #{n}" }
    text 'Some awesome text for great test'
    sample_html '<strong>heavy</strong> words'
  end
end
