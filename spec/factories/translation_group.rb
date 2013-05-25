FactoryGirl.define do
  factory :translation_group, class: I18n::Backend::Releaf::TranslationGroup do
    scope  "admin.global"
  end
end
