require "rails_helper"

describe Releaf::Content::Builders::ActionDialog, type: :class do
  class ConfirmDestroyDialogTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
  end

  class ActionDialogIncluder
    include Releaf::Content::Builders::ActionDialog
    def action; end
  end

  let(:template){ ConfirmDestroyDialogTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ ActionDialogIncluder.new(template) }

  describe "#confirm_button_text" do
    it "returns translation for humanized builder action" do
      allow(subject).to receive(:action).and_return(:move_to_the_right)
      allow(subject).to receive(:t).with("Move to the right").and_return("to the left")
      expect(subject.confirm_button_text).to eq("to the left")
    end
  end

  describe "#confirm_button_attributes" do
    it "returns hash with confirm button attributes" do
      expect(subject.confirm_button_attributes).to be_instance_of Hash
    end
  end

  describe "#confirm_button" do
    it "returns confirm button" do
      allow(subject).to receive(:confirm_button_text).and_return("Yess")
      allow(subject).to receive(:confirm_button_attributes).and_return(a: "b")
      allow(subject).to receive(:button).with("Yess", "check", a: "b").and_return("x")
      expect(subject.confirm_button).to eq("x")
    end
  end
end
