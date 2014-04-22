FactoryGirl.define do
  factory :node_route, class: ::Releaf::ContentRoute do
    sequence(:node_id) {|n| n}
    sequence(:path) {|n| "path-#{n}"}
    locale "en"
  end
end
