require "rails_helper"

describe Releaf::Builders::FormBuilder::I18nFields, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ Releaf::Builders::FormBuilder.new(:book, object, template, {}) }

  describe "#locales" do
    it "returns object globalize locales" do
      allow(subject.object.class).to receive(:globalize_locales).and_return([:de, :ru])
      expect(subject.locales).to eq([:de, :ru])
    end
  end

  describe "#default_locale" do
    before do
      allow(subject).to receive(:layout_settings).with("releaf.i18n.locale").and_return("de")
      allow(I18n).to receive(:locale).and_return(:ru)
      allow(subject).to receive(:locales).and_return([:de, :ru])
    end

    context "when layout settings has stored locale" do
      it "returns stored locale normalized to symbol" do
        expect(subject.default_locale).to eq(:de)
      end
    end

    context "when layout settings hasn't stored locale" do
      it "returns current I18n locale" do
        allow(subject).to receive(:layout_settings).with("releaf.i18n.locale").and_return(nil)
        expect(subject.default_locale).to eq(:ru)
      end
    end

    context "when stored locale or I18n locale is not within form locales" do
      it "returns first form locale" do
        allow(subject).to receive(:locales).and_return([:lv, :en])
        expect(subject.default_locale).to eq(:lv)
      end
    end
  end
end
