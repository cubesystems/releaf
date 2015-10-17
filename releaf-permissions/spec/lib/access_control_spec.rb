require "rails_helper"

describe Releaf::Permissions::AccessControl do
  class AcessControllDummyController < ActionController::Base; end

  let(:controller){ AcessControllDummyController.new }
  let(:role){ Releaf::Permissions::Role.new }
  let(:user){ Releaf::Permissions::User.new(role: role) }
  subject{ described_class.new(controller: controller) }

  before do
    allow(controller).to receive(:current_releaf_permissions_user).and_return(user)
  end

  describe "#controller_permitted" do
    before do
      allow(subject).to receive(:permitted_controllers).and_return(["a", "b"])
      allow(role).to receive(:controller_permitted?).with("c").and_return(true)
      allow(role).to receive(:controller_permitted?).with("d").and_return(false)
    end

    context "when permitted controllers contains given controller" do
      it "returns true" do
        expect(subject.controller_permitted?("a")).to be true
      end
    end

    context "when user role permit given controller" do
      it "returns true" do
        expect(subject.controller_permitted?("c")).to be true
      end
    end

    context "when neither permitted controllers contains given controller or user role permit given controller" do
      it "returns true" do
        expect(subject.controller_permitted?("d")).to be false
      end
    end
  end

  describe "#current_controller_name" do
    it "returns normalized access controller assign controller name" do
      expect(subject.current_controller_name).to eq("acess_controll_dummy")
    end
  end

  describe "#user" do
    it "returns current controller devise user instance" do
      expect(subject.user).to eq(user)
    end
  end

  describe "#permitted_controllers" do
    it "returns array with `releaf/permissions/home` and `releaf/core/errors` as permanently permitted controllers" do
      expect(subject.permitted_controllers).to match_array(['releaf/permissions/home', 'releaf/core/errors'])
    end
  end

  describe "#authorized?" do
    it "returns whether devise has signed in current user" do
      expect(controller).to receive(:releaf_permissions_user_signed_in?).and_return(true)
      expect(subject.authorized?).to be true
      expect(controller).to receive(:releaf_permissions_user_signed_in?).and_return(false)
      expect(subject.authorized?).to be false
    end
  end

  describe "#authenticate!" do
    it "returns whether devise has signed in current user" do
      expect(controller).to receive(:authenticate_releaf_permissions_user!)
      subject.authenticate!
    end
  end

  describe "#devise_model_name" do
    it "returns normalized Releaf devise model name" do
      allow(Releaf.application.config).to receive(:devise_for).and_return("asdasd/asdasd")
      expect(subject.devise_model_name).to eq("asdasd_asdasd")
    end
  end
end
