FactoryGirl.define do
  factory :node, class: ::Releaf::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "Text"
  end

  factory :text_node, class: ::Releaf::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "Text"
    content_attributes ({ text_html: "some <strong>STRIONG</strong> text" })
  end
end
