require "rails_helper"

describe Releaf::I18nDatabase::I18nEntryTranslation do
  it { is_expected.to validate_presence_of(:i18n_entry) }
  it { is_expected.to validate_presence_of(:locale) }
  it { is_expected.to validate_length_of(:locale).is_at_most(5) }
  it { subject.locale = "de"; is_expected.to validate_uniqueness_of(:i18n_entry_id).scoped_to([:locale]) }
  it { is_expected.to belong_to(:i18n_entry) }
end
