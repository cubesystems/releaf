FactoryGirl.define do

  factory :admins, :class => :'Releaf::Admin' do
    trait :admin_basic do
      email
      locale                'en'
      password              'password'
      password_confirmation 'password'
    end

    factory :admin do
      admin_basic
      name                  'Bill'
      surname               'Withers'
      email                 'admin@example.com'
      association :role, :factory => :admin_role
    end

    factory :content_admin do
      admin_basic
      name                  'Rudolph'
      surname               'Diesel'
      email                 'user@example.com'
      association :role, :factory => :content_role
    end
  end

end
