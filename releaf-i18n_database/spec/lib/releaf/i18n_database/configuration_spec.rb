require "rails_helper"

describe Releaf::I18nDatabase::Configuration do
  subject{ described_class.new(create_missing_translations: true) }

  it do
    is_expected.to have_attributes(create_missing_translations: true)
  end
end

