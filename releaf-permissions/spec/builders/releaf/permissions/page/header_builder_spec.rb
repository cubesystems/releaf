require "rails_helper"

describe Releaf::Permissions::Page::HeaderBuilder, type: :class do
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

  describe "#items" do
    it "returns array of home link, profile block and logout form content" do
      allow(subject).to receive(:home_link).and_return("a")
      allow(subject).to receive(:profile_block).and_return("b")
      allow(subject).to receive(:sign_out_form).and_return("c")
      expect(subject.items).to eq(["a", "b", "c"])
    end
  end

  describe "#profile_path" do
    it "returns profile edit url for defined profile controller" do
      expect(subject.profile_path).to eq("/admin/profile")
    end
  end

  describe "#profile_block" do
    it "returns profile block with content" do
      allow(subject).to receive(:profile_user_name).and_return("neim")
      allow(subject).to receive(:profile_path).and_return("url_b")
      content = '<a class="button profile" href="url_b"><span class="name">neim</span></a>'
      expect(subject.profile_block).to eq(content)
    end
  end

  describe "#user" do
    it "returns permissions manager user" do
      controller = Releaf::RootController.new
      allow(subject).to receive(:controller).and_return(controller)
      allow(controller).to receive(:user).and_return("x")
      expect(subject.user).to eq("x")
    end
  end

  describe "#profile_user_name" do
    it "returns title for user instance" do
      user = Releaf::Permissions::User.new(name: "a", surname: "b")
      allow(subject).to receive(:user).and_return(user)
      allow(subject).to receive(:resource_title).with(user).and_return("x t")
      expect(subject.profile_user_name).to eq("x t")
    end
  end

  describe "#sign_out_path" do
    it "returns sign out url" do
      expect(subject.sign_out_path).to eq("/admin/sign_out")
    end
  end

  describe "#sign_out_form" do
    it "returns sign out form" do
      allow(subject).to receive(:sign_out_path).and_return("url_a")
      content = %Q[
        <form class="sign-out" action="url_a" accept-charset="UTF-8" method="post">
          <input name="utf8" type="hidden" value="&#x2713;" />
          <input type="hidden" name="_method" value="delete" />
          <input type="hidden" name="yyy" value="xxx" />
          <button class="button only-icon" type="submit" title="Sign out">
            <i class="fa fa-power-off fa-icon-header"></i>
          </button>
      </form>]
      expect(subject.sign_out_form).to match_html( content )
    end
  end
end
