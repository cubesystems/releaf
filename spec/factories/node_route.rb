FactoryGirl.define do
  factory :node_route, class: ::Releaf::Content::Route do
    sequence(:node_id) {|n| n}
    sequence(:path) {|n| "path-#{n}"}
    locale "en"
  end
end
