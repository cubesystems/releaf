require "rails_helper"

describe Releaf::Builders::Page::HeaderBuilder, type: :class do
  class PageHeaderBuilderTestHelper < ActionView::Base
    include Rails.application.routes.url_helpers
    include FontAwesome::Rails::IconHelper

    def protect_against_forgery?
      true
    end

    def form_authenticity_token
      "xxx"
    end

    def request_forgery_protection_token
      "yyy"
    end
  end

  subject { described_class.new(template) }
  let(:template){ PageHeaderBuilderTestHelper.new }

  describe "#output" do
    it "returns safely joined items" do
      allow(subject).to receive(:items).and_return([ '<', ActiveSupport::SafeBuffer.new(">")])
      expect(subject.output).to eq("&lt;>")
    end
  end

  describe "#items" do
    it "returns array of home link, profile block and logout form content" do
      allow(subject).to receive(:home_link).and_return("a")
      expect(subject.items).to eq(["a"])
    end
  end

  describe "#home_link" do
    it "returns home link with a logo" do
      allow(subject).to receive(:home_url).and_return("www.xxx")
      allow(subject).to receive(:home_text).and_return("Rrr")
      allow(subject).to receive(:home_image_path).and_return("releaf/foo.png")
      content = '<a class="home" href="www.xxx"><img alt="Rrr" src="/images/releaf/foo.png" /></a>'
      expect(subject.home_link).to eq(content)
    end
  end

  describe "#home_url" do
    it "returns home url" do
      expect(subject.home_url).to eq("/admin")
    end
  end

  describe "#home_image_path" do
    it "returns image to the logo image asset" do
      expect(subject.home_image_path).to eq("releaf/logo.png")
    end
  end

  describe "#home_text" do
    it "returns releaf home link text" do
      expect(subject.home_text).to eq("Releaf")
    end
  end
end
