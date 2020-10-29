FactoryBot.define do
  factory :users, class: Releaf::Permissions::User do
    trait :user_basic do
      email
      name
      surname
      locale                { 'en' }
      password              { 'password' }
      password_confirmation { 'password' }
    end

    factory :user do
      user_basic
      association :role, factory: :admin_role
    end

    factory :content_user do
      user_basic
      association :role, factory: :content_role
    end
  end
end
