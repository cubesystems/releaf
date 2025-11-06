FactoryBot.define do
  factory :roles, :class => Releaf::Permissions::Role do
    sequence(:name) {|n| "role #{n}"}

    factory :admin_role do
      default_controller { "releaf/permissions/users" }
      after(:create) do |role|
        Releaf.application.config.available_controllers.each do|controller|
          role.permissions.create!(permission: "controller.#{controller}")
        end
      end
    end

    factory :content_role do
      default_controller { "foo" }
      after(:create) do |role|
        role.permissions.create!(permission: "controller.admin/foo")
      end
    end
  end
end
