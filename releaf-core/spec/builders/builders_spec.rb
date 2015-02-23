require 'spec_helper'

describe Releaf::Builders, type: :class do
  module Admin::Advanced
    class FormBuilder
    end
    class AuthorsController
    end
  end

  class Admin::Advanced::Builders < Releaf::Builders; end

  describe ".builder_class" do
    it "returns first resolved builder class from given and inherited scopes" do
      allow(described_class).to receive(:inherited_builder_scopes).and_return(["Releaf::Permissions::Users"])
      expect(described_class).to receive(:builder_defined?).with("Admin::Advanced::FormBuilder")
        .and_return(false).ordered
      expect(described_class).to receive(:builder_defined?).with("Releaf::Permissions::Users::FormBuilder")
        .and_return(true).ordered
      expect(described_class.builder_class(["Admin::Advanced"], :form)).to eq(Releaf::Permissions::Users::FormBuilder)

      expect(described_class).to receive(:builder_defined?).with("Admin::Advanced::FormBuilder")
        .and_return(true)
      expect(described_class.builder_class(["Admin::Advanced"], :form)).to eq(Admin::Advanced::FormBuilder)
    end

    context "when no builders exists for given scope and type" do
      it "raises error" do
        allow(described_class).to receive(:inherited_builder_scopes).and_return([])
        error_message = 'unexisting builder (type: form; scopes: Admin::Simple)'
        expect{ described_class.builder_class(["Admin::Simple"], :form) }.to raise_error(ArgumentError, error_message)

        error_message = 'unexisting builder (type: asd; scopes: Admin::Advanced)'
        expect{ described_class.builder_class(["Admin::Advanced"], :asd) }.to raise_error(ArgumentError, error_message)
      end
    end
  end

  describe ".builder_defined?" do
    it "returns whether given class is loaded and exists as constant" do
      allow(Object).to receive(:const_defined?).and_call_original
      allow(Object).to receive(:const_defined?).with("Something").and_return(true)
      expect(described_class.builder_defined?("Something")).to be true

      allow(Object).to receive(:const_defined?).with("Something").and_return(false)
      expect(described_class.builder_defined?("Something")).to be false
    end

    context "when eager load is switched off" do
      it "call application eager load" do
        allow(Rails.application.config).to receive(:eager_load).and_return(false)
        expect(Rails.application).to receive(:eager_load!)
        described_class.builder_defined?("Something")

        allow(Rails.application.config).to receive(:eager_load).and_return(true)
        expect(Rails.application).to_not receive(:eager_load!)
        described_class.builder_defined?("Something")
      end
    end
  end

  describe ".inherited_builder_scopes" do
    it "returns inherited classes except Object and BasicObject" do
      expect(described_class.inherited_builder_scopes).to eq(["Releaf::Builders"])
      expect(Admin::Advanced::Builders.inherited_builder_scopes).to eq(["Admin::Advanced::Builders", "Releaf::Builders"])
    end
  end
end
