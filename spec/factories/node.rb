FactoryGirl.define do
  factory :node, class: ::Releaf::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "fake_type"
  end

  factory :node_text, class: ::Releaf::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "Text"
  end

end
