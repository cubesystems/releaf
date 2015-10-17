require "rails_helper"

describe Releaf::Builders::Page::LayoutBuilder, type: :class do
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

  describe "#controller_body_classes" do
    it "returns normalized html classes from controller classes" do
      allow(subject).to receive(:controller_classes).and_return([Releaf::BaseController, Releaf::Permissions::RolesController])
      expect(subject.controller_body_classes).to eq(["controller-releaf-base", "controller-releaf-permissions-roles"])
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

