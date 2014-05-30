FactoryGirl.define do
  factory :roles, :class => Releaf::Permissions::Role do
    sequence(:name) {|n| "role #{n}"}

    factory :admin_role do
      default_controller "releaf/permissions/users"
      permissions Releaf.available_controllers
    end

    factory :content_role do
      default_controller "releaf/content/nodes"
      permissions ['releaf/content/nodes']
    end
  end
end
