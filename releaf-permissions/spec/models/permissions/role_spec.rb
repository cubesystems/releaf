require "spec_helper"

describe Releaf::Permissions::Role do
  it { is_expected.to serialize(:permissions).as(Array) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:default_controller) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_exception) }
  end
end
