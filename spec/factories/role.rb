FactoryGirl.define do
  factory :roles, :class => :'Releaf::Role' do
    sequence(:name) {|n| "role #{n}"}

    factory :admin_role do
      default_controller "releaf_admins"
      releaf_content_permission true
      releaf_translations_permission true
      releaf_admins_permission true
      releaf_roles_permission true
    end

    factory :content_role do
      default_controller "releaf_content"
      releaf_content_permission true
    end

  end
end
