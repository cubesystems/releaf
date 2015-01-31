require "spec_helper"

describe Releaf::I18nDatabase::TranslationData do

  it { is_expected.to validate_presence_of(:translation) }
  it { is_expected.to validate_presence_of(:lang) }
  it { is_expected.to validate_length_of(:lang).is_at_most(5) }
  it {
    FactoryGirl.create(:translation_data)
    is_expected.to validate_uniqueness_of(:translation_id).scoped_to([:lang])
  }
  it { is_expected.to belong_to(:translation) }
end
