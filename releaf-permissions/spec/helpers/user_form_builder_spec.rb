require "spec_helper"

describe Releaf::Permissions::UserFormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Permissions::Role.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#field_names" do
    it "returns name, surname, locale, role_id, email, password and password_confirmation as field names array" do
      expect(subject.field_names).to eq(%w(name surname locale role_id email password password_confirmation))
    end
  end

  describe "#render_locale" do
    it "pass localized controller options to releaf item field" do
      allow(Releaf).to receive(:available_admin_locales).and_return(["de", "ze"])
      allow(subject).to receive(:releaf_item_field).with(:locale, options: {select_options: ["de", "ze"]}).and_return("x")
      expect(subject.render_locale).to eq("x")
    end
  end
end
