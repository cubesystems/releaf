require "rails_helper"

describe Releaf::Permissions::User do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:surname) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_presence_of(:email) }
    it { create(:user); is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:role) }
  end

  describe "#releaf_title" do
    it "returns concated name and surname" do
      subject.name = "John"
      subject.surname = "Baum"
      expect(subject.releaf_title).to eq("John Baum")
    end
  end

  describe "#password_required?" do
    context "when existing record" do
      before do
        allow(subject).to receive(:new_record?).and_return(false)
      end

      context "when new password is blank" do
        it "returns true" do
          allow(subject).to receive(:encrypted_password).and_return("")
          expect(subject.password_required?).to be true
        end
      end

      context "when new password is not blank" do
        it "returns false" do
          allow(subject).to receive(:encrypted_password).and_return("asdasd")
          expect(subject.password_required?).to be false
        end
      end
    end

    context "when new record" do
      it "returns true" do
        allow(subject).to receive(:new_record?).and_return(true)
        expect(subject.password_required?).to be true
      end
    end
  end
end
