FactoryGirl.define do
  factory :node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "TextPage"
  end

  factory :text_page_node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "TextPage"
    content_attributes ({ text_html: "some <strong>STRIONG</strong> text" })
  end
end
