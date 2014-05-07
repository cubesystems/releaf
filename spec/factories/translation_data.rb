FactoryGirl.define do
 factory :translation_data, class: Releaf::TranslationData do
    translation {Releaf::Translation.find_by_key("admin.global.save") || FactoryGirl.create(:translation, :key => "admin.global.save")}
    lang "en"
    localization "Save"
  end
end
