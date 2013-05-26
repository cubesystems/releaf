# encoding: UTF-8

require "spec_helper"

describe I18n::Backend::Releaf::TranslationData do

  it { should have(1).error_on(:translation_id) }
  it { should have(1).error_on(:lang) }
  it {
    FactoryGirl.create(:translation_data)
    should validate_uniqueness_of(:translation_id).scoped_to([:lang])
  }
  it { should belong_to(:translation) }
end
