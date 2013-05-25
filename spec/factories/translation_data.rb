FactoryGirl.define do
 factory :translation_data, class: I18n::Backend::Releaf::TranslationData do
    translation {I18n::Backend::Releaf::Translation.find_by_key("admin.global.save") || FactoryGirl.create(:translation, :key => "admin.global.save")}
    lang "en"
    localization "Save"
  end
end
