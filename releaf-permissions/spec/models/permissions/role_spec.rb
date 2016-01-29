require "rails_helper"

describe Releaf::Permissions::Role do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:default_controller) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end
end
