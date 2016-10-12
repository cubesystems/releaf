require "rails_helper"

describe Releaf::I18nDatabase::Configuration do
  subject{ described_class.new(translation_auto_creation: true, translation_auto_creation_exclusion_patterns: [1, 2]) }

  it do
    is_expected.to have_attributes(translation_auto_creation: true)
    is_expected.to have_attributes(translation_auto_creation_exclusion_patterns: [1, 2])
  end
end

