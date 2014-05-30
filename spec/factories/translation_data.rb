FactoryGirl.define do
 factory :translation_data, class: Releaf::I18nDatabase::TranslationData do
    translation {Releaf::I18nDatabase::Translation.find_by_key("admin.global.save") || FactoryGirl.create(:translation, :key => "admin.global.save")}
    lang "en"
    localization "Save"
  end
end
