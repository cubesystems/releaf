require 'rails_helper'

describe Releaf::Builders, type: :class do
  module Admin::Advanced
    class FormBuilder
    end
    class AuthorsController
    end
  end

  class Admin::Advanced::Builders < Releaf::Builders; end

  describe ".builder_class" do
    before do
      allow(described_class).to receive(:inherited_builder_scopes).and_return(["Releaf::Permissions::Users"])
    end

    it "returns first existing builder class from given and inherited scopes" do
      expect(described_class).to receive(:builder_class_at_scope).with("Admin::Advanced", :form)
        .and_return(nil).ordered
      expect(described_class).to receive(:builder_class_at_scope).with("Releaf::Permissions::Users", :form)
        .and_return(Releaf::Permissions::Users::FormBuilder).ordered

      expect(described_class.builder_class(["Admin::Advanced"], :form)).to eq(Releaf::Permissions::Users::FormBuilder)
    end

    context "when no builders exists for given scope and type" do
      it "raises error" do
        allow(described_class).to receive(:builder_class_at_scope).and_return(nil)
        error_message = 'unexisting builder (type: form; scopes: Admin::Advanced)'
        expect{ described_class.builder_class(["Admin::Advanced"], :form) }.to raise_error(ArgumentError, error_message)
      end
    end
  end

  describe ".builder_class_at_scope" do
    before do
      allow(described_class).to receive(:constant_defined_at_scope?)
        .with("Releaf::Builders", Object).and_return(true)
      allow(described_class).to receive(:constant_defined_at_scope?)
        .with("Releaf::Builders::EditBuilder", Releaf::Builders).and_return(true)
    end

    context "when scope and builder exists" do
      it "returns builder class" do
        expect(described_class.builder_class_at_scope("Releaf::Builders", :edit)).to eq(Releaf::Builders::EditBuilder)
      end
    end

    context "when scope exists but builder does not" do
      it "returns nil" do
        allow(described_class).to receive(:constant_defined_at_scope?)
          .with("Releaf::Builders", Object).and_return(false)
        expect(described_class.builder_class_at_scope("Releaf::Builders", :edit)).to be nil
      end
    end

    context "when scope does not exist" do
      it "returns nil" do
        allow(described_class).to receive(:constant_defined_at_scope?)
          .with("Releaf::Builders::EditBuilder", Releaf::Builders).and_return(false)
        expect(described_class.builder_class_at_scope("Releaf::Builders", :edit)).to be nil
      end
    end
  end

  describe ".constant_defined_at_scope?" do
    before do
      allow(Releaf).to receive(:const_get).and_call_original
    end

    it "checks constant existence within given scope" do
      expect(Releaf).to receive(:const_get).with("Releaf::Builders::FormBuilder").and_call_original
      described_class.constant_defined_at_scope?("Releaf::Builders::FormBuilder", Releaf)

      expect(Releaf).to receive(:const_get).with("Releaf::Builders::AnotherFormBuilder").and_call_original
      described_class.constant_defined_at_scope?("Releaf::Builders::AnotherFormBuilder", Releaf)

      expect(Admin).to receive(:const_get).with("Admin:xx").and_call_original
      described_class.constant_defined_at_scope?("Admin:xx", Admin)
    end

    context "when constant exists at given namespace" do
      it "returns true" do
        expect(described_class.constant_defined_at_scope?("Releaf::Builders::FormBuilder", Releaf)).to be true
      end

      it "compare constant with constant at given namespace and check whether it exists" do
        allow(Admin).to receive(:const_get).with("Admin:xx").and_return(true)
        expect(described_class.constant_defined_at_scope?("Admin:xx", Admin)).to be false
      end
    end

    context "when NameError raised" do
      context "when error message matches against constant name pattern" do
        it "returns false" do
          allow(described_class).to receive(:constant_name_error?)
            .with("uninitialized constant Releaf::Builders::AnotherFormBuilder", "Releaf::Builders::AnotherFormBuilder")
            .and_return(true)
          expect(described_class.constant_defined_at_scope?("Releaf::Builders::AnotherFormBuilder", Releaf)).to be false
        end
      end

      context "when error message does not match against constant name pattern" do
        it "reraises it" do
          allow(described_class).to receive(:constant_name_error?)
            .with("uninitialized constant Releaf::Builders::AnotherFormBuilder", "Releaf::Builders::AnotherFormBuilder")
            .and_return(false)

          expect{ described_class.constant_defined_at_scope?("Releaf::Builders::AnotherFormBuilder", Releaf) }
            .to raise_error(NameError, "uninitialized constant Releaf::Builders::AnotherFormBuilder")
        end
      end
    end

    context "when any other error raised" do
      it "does not rescue it" do
        allow(Releaf).to receive(:const_get).with("Releaf::Builders::FormBuilder")
                  .and_raise(ArgumentError, "xxx")
        expect(described_class).to_not receive(:constant_name_error?)

        expect{ described_class.constant_defined_at_scope?("Releaf::Builders::FormBuilder", Releaf) }
          .to raise_error(ArgumentError, "xxx")
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
