require "rails_helper"

describe Releaf::Permissions::ControllerSupport do
  let(:user){ Releaf::Permissions::User.new(locale: "de") }

  class AcessControllDummyController < Releaf::ActionController
    include Releaf::Permissions::ControllerSupport
  end

  subject{ AcessControllDummyController.new }

  before do
    allow(subject).to receive(:current_releaf_permissions_user).and_return(user)
  end

  describe "before filters" do
    it "prepends `:authenticate!, :verify_controller_access!, :set_locale` before filters" do
      all_before_actions = subject._process_action_callbacks.select{|f| f.kind == :before}.map{|f| f.filter }
      expect(all_before_actions).to start_with(:authenticate!, :verify_controller_access!, :set_locale)
    end
  end

  describe "#set_locale" do
    it "assigns user locale to I18n locale" do
      expect(I18n).to receive(:locale=).with("de")
      subject.set_locale
    end
  end

  describe "#verify_controller_access!" do
    let(:access_control){ Releaf::Permissions::AccessControl.new(user: user) }

    before do
      allow(subject).to receive(:short_name).and_return("some_controller")
      allow(Releaf.application.config.permissions.access_control).to receive(:new)
        .with(user: user).and_return(access_control)
    end

    context "when controller is not permitted" do
      it "raises `Releaf::AccessDenied exception`" do
        allow(access_control).to receive(:controller_permitted?).with("some_controller").and_return(false)
        expect{ subject.verify_controller_access! }.to raise_error(Releaf::AccessDenied)
      end
    end

    context "when controller is permitted" do
      it "does not raise `Releaf::AccessDenied exception`" do
        allow(access_control).to receive(:controller_permitted?).with("some_controller").and_return(true)
        expect{ subject.verify_controller_access! }.to_not raise_error
      end
    end
  end

  describe "#user" do
    it "returns current controller devise user instance" do
      expect(subject.user).to eq(user)
    end
  end

  describe "#authorized?" do
    it "returns whether devise has signed in current user" do
      allow(subject).to receive(:releaf_permissions_user_signed_in?).and_return(true)
      expect(subject.authorized?).to be true

      allow(subject).to receive(:releaf_permissions_user_signed_in?).and_return(false)
      expect(subject.authorized?).to be false
    end
  end

  describe "#authenticate!" do
    it "returns whether devise has signed in current user" do
      expect(subject).to receive(:authenticate_releaf_permissions_user!)
      subject.authenticate!
    end
  end
end
