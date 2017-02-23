require "rails_helper"

describe Releaf::Builders::Page::LayoutBuilder, type: :class do
  class DummyBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    def output; end
  end

  class DummyAssetsResolver
    def self.controller_assets(_a, _b); end
  end

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

  class NewRolesController < Releaf::Permissions::RolesController
  end

  subject { described_class.new(template) }
  let(:template){ PageHeaderBuilderTestHelper.new }

  describe "#controller_classes" do
    it "returns array of ignorable ancester classes" do
      allow(subject).to receive(:controller).and_return(NewRolesController.new)
      expect(subject.controller_classes).to eq([Releaf::Permissions::RolesController, NewRolesController])

      allow(subject).to receive(:controller).and_return(Releaf::Permissions::RolesController.new)
      expect(subject.controller_classes).to eq([Releaf::Permissions::RolesController])

      allow(subject).to receive(:controller).and_return(Releaf::Permissions::SessionsController.new)
      expect(subject.controller_classes).to eq([Releaf::Permissions::SessionsController])
    end
  end

  describe "#features" do
    it "returns controller layout features" do
      allow(subject).to receive(:controller).and_return(NewRolesController.new)
      allow(subject.controller).to receive(:layout_features).and_return([:a, :c])
      expect(subject.features).to eq([:a, :c])
    end
  end

  describe "#header_builder" do
    it "returns `Releaf::Builders::Page::HeaderBuilder` class" do
      expect(subject.header_builder).to eq(Releaf::Builders::Page::HeaderBuilder)
    end
  end

  describe "#assets_resolver" do
    it "returns `Releaf::AssetsResolver` class" do
      expect(subject.assets_resolver).to eq(Releaf::AssetsResolver)
    end
  end

  describe "#feature_available?" do
    before do
      allow(subject).to receive(:features).and_return([:a, :b])
    end

    it "returns true when feature is available" do
      expect(subject.feature_available?(:a)).to be true
    end

    it "returns false when feature is not available" do
      expect(subject.feature_available?(:c)).to be false
    end
  end

  describe "#stylesheets" do
    it "returns stylesheets from assets resolver for given controller" do
      allow(subject).to receive(:assets_resolver).and_return(DummyAssetsResolver)
      allow(subject).to receive(:controller_name).and_return("_controller")
      allow(DummyAssetsResolver).to receive(:controller_assets).with("_controller", :stylesheets)
        .and_return("x")
      expect(subject.stylesheets).to eq("x")
    end
  end

  describe "#javascripts" do
    it "returns javascripts from assets resolver for given controller" do
      allow(subject).to receive(:assets_resolver).and_return(DummyAssetsResolver)
      allow(subject).to receive(:controller_name).and_return("_controller")
      allow(DummyAssetsResolver).to receive(:controller_assets).with("_controller", :javascripts)
        .and_return("y")
      expect(subject.javascripts).to eq("y")
    end
  end

  describe "#header" do
    it "returns menu builder output wrapped within `aside` tag" do
      menu_builder = DummyBuilder.new(template)
      allow(menu_builder).to receive(:output).and_return("_header")
      allow(DummyBuilder).to receive(:new).with(template).and_return(menu_builder)
      allow(subject).to receive(:header_builder).and_return(DummyBuilder)
      allow(subject).to receive(:tag).with(:header, "_header").and_return("<_header>")

      expect(subject.header).to eq("<_header>")
    end
  end

  describe "#menu" do
    it "returns menu builder output wrapped within `aside` tag" do
      menu_builder = DummyBuilder.new(template)
      allow(menu_builder).to receive(:output).and_return("_menu")
      allow(DummyBuilder).to receive(:new).with(template).and_return(menu_builder)
      allow(subject).to receive(:menu_builder).and_return(DummyBuilder)
      allow(subject).to receive(:tag).with(:aside, "_menu").and_return("<_menu>")

      expect(subject.menu).to eq("<_menu>")
    end
  end

  describe "#menu_builder" do
    it "returns `Releaf::Builders::Page::MenuBuilder` class" do
      expect(subject.menu_builder).to eq(Releaf::Builders::Page::MenuBuilder)
    end
  end

  describe "#body" do
    it "returns body with body attributes and" do
      allow(subject).to receive(:body_atttributes).and_return(class: ["xx", "y"], id: "121212")
      allow(subject).to receive(:body_content_blocks){|*args, &block| expect(block.call).to eq("x") }
        .and_return(["a<b>".html_safe, "b<i>", "c<d>".html_safe])
      expect(subject.body{ "x" }).to eq("<body class=\"xx y\" id=\"121212\">a<b>b&lt;i&gt;c<d></body>")
    end
  end

      #parts = []
      #parts << header if feature_available?(:header)
      #parts << menu if feature_available?(:sidebar)
      #parts << tag(:main, id: "main"){ yield } if feature_available?(:main)
      #parts << notifications
      #parts << assets(:javascripts, :javascript_include_tag)
      #parts


  describe "#body_content_blocks" do
    before do
      allow(subject).to receive(:feature_available?).with(:header).and_return(true)
      allow(subject).to receive(:feature_available?).with(:sidebar).and_return(true)
      allow(subject).to receive(:feature_available?).with(:main).and_return(true)

      allow(subject).to receive(:assets).with(:javascripts, :javascript_include_tag).and_return("_assets_")
      allow(subject).to receive(:header).and_return("_header_")
      allow(subject).to receive(:menu).and_return("_menu_")
      allow(subject).to receive(:notifications).and_return("_notifications_")
      allow(subject).to receive(:tag).with(:main, id: :main){|*args, &block| expect(block.call).to eq("x") }.and_return("body content")
    end

    it "returns body with body attributes and" do
      expect(subject.body_content_blocks{ "x" }).to eq(["_header_", "_menu_", "body content", "_notifications_", "_assets_"])
    end

    it "skips header when header feature not available" do
      allow(subject).to receive(:feature_available?).with(:header).and_return(false)
      expect(subject.body_content_blocks{ "x" }).to eq(["_menu_", "body content", "_notifications_", "_assets_"])
    end

    it "skips menu when sidebar feature not available" do
      allow(subject).to receive(:feature_available?).with(:sidebar).and_return(false)
      expect(subject.body_content_blocks{ "x" }).to eq(["_header_", "body content", "_notifications_", "_assets_"])
    end

    it "skips main conrtent when main feature not available" do
      allow(subject).to receive(:feature_available?).with(:main).and_return(false)
      expect(subject.body_content_blocks{ "x" }).to eq(["_header_", "_menu_", "_notifications_", "_assets_"])
    end
  end

  describe "#controller_body_classes" do
    it "returns normalized html classes from controller classes" do
      allow(subject).to receive(:controller_classes).and_return([Releaf::ActionController, Releaf::Permissions::RolesController])
      expect(subject.controller_body_classes).to eq(["controller-releaf-action", "controller-releaf-permissions-roles"])
    end
  end

  describe "#settings_path" do
    it "returns root controller settings path" do
      allow(subject).to receive(:url_for).with(action: "store_settings", controller: "/releaf/root", only_path: true)
        .and_return("asdasdasd")
      expect(subject.settings_path).to eq("asdasdasd")
    end
  end

  describe "#body_atttributes" do
    it "returns hash with classes, data-settings-path and data-layout-features" do
      allow(subject).to receive(:features).and_return([:top, :bottom])
      allow(subject).to receive(:controller_body_classes).and_return(["a", "b"])
      allow(subject).to receive(:settings_path).and_return("/xxx/sett")
      expect(subject.body_atttributes).to eq(class: ["application-dummy", "a", "b"],
                                             "data-settings-path" => "/xxx/sett",
                                             "data-layout-features" => "top bottom")
    end
  end

  describe "#head_blocks" do
    it "returns array" do
      {
        title: :title_sym,
        meta: :meta_sym,
        favicons: :favicon_sym,
        ms_tile: :ms_tile_sym,
        assets: :assets_sym,
        csrf: :csrf_sym,
      }.each_pair do |method, stub_answer|
        allow(subject).to receive(method).and_return stub_answer
      end

      expect(subject.head_blocks).to match_array(
        [
          :title_sym,
          :meta_sym,
          :favicon_sym,
          :ms_tile_sym,
          :assets_sym,
          :csrf_sym,
        ]
      )
    end
  end
end

