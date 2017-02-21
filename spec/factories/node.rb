FactoryGirl.define do
  factory :node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "HomePage"
  end

  factory :other_node, class: ::OtherSite::OtherNode do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "HomePage"
  end

  factory :home_page_node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "HomePage"
    content_attributes ({ intro_text_html: "some <strong>STRRRONG</strong> text" })
  end

  factory :other_home_page_node, class: ::OtherSite::OtherNode do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "HomePage"
    content_attributes ({ intro_text_html: "some <strong>STRRRONG</strong> text" })
  end

  factory :text_page_node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "TextPage"
    content_attributes ({ text_html: "some <strong>STRIONG</strong> text" })
  end

  factory :other_text_page_node, class: ::OtherSite::OtherNode do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "TextPage"
    content_attributes ({ text_html: "some <strong>STRIONG</strong> text" })
  end

  factory :banner_page_node, class: ::Node do
    sequence(:name) {|n| "node #{n}"}
    sequence(:slug) {|n| "node-#{n}"}
    content_type "BannerPage"
    content_attributes ({})
  end


end
