require "rails_helper"

describe Releaf::ResourceFields do
  subject{ described_class.new(Book) }

  describe "#excluded_attributes" do
    it "returns array with excluded attributes" do
      expect(subject.excluded_attributes)
        .to eq(%w(id created_at updated_at password password_confirmation encrypted_password))
    end
  end
end
