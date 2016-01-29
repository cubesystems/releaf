require "rails_helper"

describe Releaf::Builders::Page::LayoutBuilder, type: :class do
  class DummyBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    def output; end
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

  describe "#header_builder" do
    it "returns `Releaf::Builders::Page::HeaderBuilder` class" do
      expect(subject.header_builder).to eq(Releaf::Builders::Page::HeaderBuilder)
    end
  end

  describe "#menu" do
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
      allow(subject).to receive(:assets).with(:javascripts, :javascript_include_tag).and_return("_assets_")
      allow(subject).to receive(:body_atttributes).and_return(class: ["xx", "y"], id: "121212")
      allow(subject).to receive(:body_content){|*args, &block| expect(block.call).to eq("x") }.and_return("body content")
      expect(subject.body{ "x" }).to eq("<body class=\"xx y\" id=\"121212\">body content_assets_</body>")
    end
  end

  describe "#controller_body_classes" do
    it "returns normalized html classes from controller classes" do
      allow(subject).to receive(:controller_classes).and_return([Releaf::BaseController, Releaf::Permissions::RolesController])
      expect(subject.controller_body_classes).to eq(["controller-releaf-base", "controller-releaf-permissions-roles"])
    end
  end

  describe "#settings_path" do
    it "returns root controller settings path" do
      allow(subject).to receive(:url_for).with(action: "store_settings", controller: "releaf/core/root", only_path: true)
        .and_return("asdasdasd")
      expect(subject.settings_path).to eq("asdasdasd")
    end
  end

  describe "#body_atttributes" do
    it "returns hash with classes and data-settings-path" do
      allow(subject).to receive(:controller_body_classes).and_return(["a", "b"])
      allow(subject).to receive(:settings_path).and_return("/xxx/sett")
      expect(subject.body_atttributes).to eq(class: ["application-dummy", "a", "b"], "data-settings-path" => "/xxx/sett")
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

