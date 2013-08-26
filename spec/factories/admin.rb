FactoryGirl.define do

  factory :admins, :class => :'Releaf::Admin' do
    trait :admin_basic do
      email
      name
      surname
      locale                'en'
      password              'password'
      password_confirmation 'password'
    end

    factory :admin do
      admin_basic
      association :role, :factory => :admin_role
    end

    factory :content_admin do
      admin_basic
      association :role, :factory => :content_role
    end
  end
end
