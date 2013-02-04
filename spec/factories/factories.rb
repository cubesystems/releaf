FactoryGirl.define do
  # sequence(:email) {|n| "person-#{n}@example.com" }

  factory :admin, :class => :'Releaf::Admin' do
    sequence(:email) {|n| "person-#{n}@example.com" }
    name                  'admin'
    surname               'admin'
    password              'password'
    password_confirmation 'password'
  end

  factory :role, :class => :'Releaf::Role' do
    # sequenece(:name) {|n| "role #{n}"}
    name 'role'

    trait :admin do
      admin_permission true
    end

    trait :default do
      default true
    end
  end

end
