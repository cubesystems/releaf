FactoryGirl.define do
 factory :translation, class: I18n::Backend::Releaf::Translation do
    translation_group {I18n::Backend::Releaf::TranslationGroup.find_by_scope("admin.global") || FactoryGirl.create(:translation_group, :scope => "admin.global")}
    key "save"
  end
end
