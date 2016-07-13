require "rails_helper"

describe Releaf::I18nDatabase::Translations::BuildersCommon, type: :class do
  class I18nBuildersCommonInheriter < Releaf::Builders::IndexBuilder
    include Releaf::I18nDatabase::Translations::BuildersCommon
  end
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:subject){ I18nBuildersCommonInheriter.new(template) }

  describe "#action_url" do
    before do
      request = ActionDispatch::Request.new("X")
      allow(request).to receive(:query_parameters).and_return(a: "b", c: "d")
      allow(subject).to receive(:request).and_return(request)
    end

    it "returns url for given action with current query params" do
      allow(subject).to receive(:url_for).with(a: "b", c: "d", action: :edit).and_return("url")
      expect(subject.action_url(:edit)).to eq("url")
    end

    context "when extra params given" do
      it "merges given params to url" do
        allow(subject).to receive(:url_for).with(a: "b", c: "z", action: :edit, format: "xx").and_return("url")
        expect(subject.action_url(:edit, format: "xx", c: "z")).to eq("url")
      end
    end
  end

  describe "#export_button" do
    it "returns export button" do
      allow(subject).to receive(:t).with("Export").and_return("exp")
      allow(subject).to receive(:action_url).with(:export, format: :xlsx).and_return("_exp_url_")
      allow(subject).to receive(:button).with("exp", "download", class: "secondary", href: "_exp_url_").and_return("btn")
      expect(subject.export_button).to eq('btn')
    end
  end
end
