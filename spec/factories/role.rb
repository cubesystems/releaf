FactoryGirl.define do
  factory :roles, :class => Releaf::Role do
    sequence(:name) {|n| "role #{n}"}

    factory :admin_role do
      default_controller "releaf/admins"
      permissions Releaf.available_admin_controllers
    end

    factory :content_role do
      default_controller "releaf/content"
      permissions ['releaf/content']
    end
  end
end
