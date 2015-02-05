require "spec_helper"

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
      allow(subject).to receive(:profile_block).and_return("b")
      allow(subject).to receive(:sign_out_form).and_return("c")
      expect(subject.items).to eq(["a", "b", "c"])
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


  describe "#profile_url" do
    it "returns profile edit url for defined profile controller" do
      expect(subject.profile_url).to eq("/admin/profile")

      allow(subject).to receive(:profile_controller).and_return("/releaf/home")
      expect{ subject.profile_url }
        .to raise_error(ActionController::UrlGenerationError, 'No route matches {:action=>"edit", :controller=>"releaf/home"}')
    end
  end

  describe "#profile_settings_url" do
    it "returns profile edit url for defined profile controller" do
      expect(subject.profile_settings_url).to eq("/admin/profile/settings")

      allow(subject).to receive(:profile_controller).and_return("/releaf/home")
      expect{ subject.profile_settings_url }
        .to raise_error(ActionController::UrlGenerationError, 'No route matches {:action=>"settings", :controller=>"releaf/home"}')
    end
  end

  describe "#profile_controller" do
    it "returns releaf permissions profile controller" do
      expect(subject.profile_controller).to eq("/releaf/permissions/profile")
    end
  end

  describe "#profile_block" do
    it "returns profile block with content" do
      allow(subject).to receive(:profile_user_name).and_return("neim")
      allow(subject).to receive(:profile_user_image).and_return("image")
      allow(subject).to receive(:profile_settings_url).and_return("url_a")
      allow(subject).to receive(:profile_url).and_return("url_b")
      content = '<a class="profile" href="url_b" data-settings-url="url_a"><span class="name">neim</span>image</a>'
      expect(subject.profile_block).to eq(content)
    end
  end

  describe "#profile_user_image" do
    it "returns gravatar image for current admin user email with http or https url" do
      admin = Releaf::Permissions::User.new(email: "xx")
      allow(subject).to receive(:user).and_return(admin)
      allow(subject).to receive(:profile_user_name).and_return("neim")
      allow(subject).to receive_message_chain(:request, :ssl?).and_return(true)
      content = '<img alt="neim" class="avatar" src="https://secure.gravatar.com/avatar/9336ebf25087d91c818ee6e9ec29f8c1?default=mm&secure=true&size=36" width="36" height="36" />'
      expect(subject.profile_user_image).to eq(content)

      allow(subject).to receive_message_chain(:request, :ssl?).and_return(false)
      content = '<img alt="neim" class="avatar" src="http://gravatar.com/avatar/9336ebf25087d91c818ee6e9ec29f8c1?default=mm&secure=false&size=36" width="36" height="36" />'
      expect(subject.profile_user_image).to eq(content)

      admin.email = "a"
      content = '<img alt="neim" class="avatar" src="http://gravatar.com/avatar/0cc175b9c0f1b6a831c399e269772661?default=mm&secure=false&size=36" width="36" height="36" />'
      expect(subject.profile_user_image).to eq(content)
    end
  end

  describe "#user" do
    it "returns permissions manager user" do
      access_control = double(Releaf::Permissions::AccessControl)
      allow(subject).to receive(:access_control).and_return(access_control)
      allow(access_control).to receive(:user).and_return("x")
      expect(subject.user).to eq("x")
    end
  end

  describe "#profile_user_name" do
    it "returns profile user name" do
      admin = Releaf::Permissions::User.new(name: "a", surname: "b")
      allow(subject).to receive(:user).and_return(admin)
      expect(subject.profile_user_name).to eq("a b")
    end
  end

  describe "#sign_out_url" do
    it "returns sign out url" do
      expect(subject.sign_out_url).to eq("/admin/sign_out")
    end
  end

  describe "#sign_out_form" do
    it "returns sign out form" do
      allow(subject).to receive(:sign_out_url).and_return("url_a")
      content = '<form class="sign-out" action="url_a" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="_method" value="delete" /><input type="hidden" name="yyy" value="xxx" /><button type="submit"><i class="fa fa-power-off fa-icon-header"></i></button></form>'
      expect(subject.sign_out_form).to eq(content)
    end
  end
end
