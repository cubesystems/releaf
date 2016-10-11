require "rails_helper"

describe Releaf::I18nDatabase::Configuration do
  subject{ described_class.new(create_missing_translations: true, auto_creation_exception_patterns: [1, 2]) }

  it do
    is_expected.to have_attributes(create_missing_translations: true)
    is_expected.to have_attributes(auto_creation_exception_patterns: [1, 2])
  end
end

