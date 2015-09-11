require "spec_helper"

describe Releaf::Core::Responders, type: :controller do
  subject{ Releaf::BaseController.new }

  describe "#respond_with" do
    before do
      allow(subject).to receive(:active_responder).and_return(Releaf::Core::Responders::AfterSaveResponder)
      allow(subject).to receive(:request).and_return(request)
      allow(subject).to receive(:content_type).and_return(:html)
    end

    context "when no responder defined within options" do
      it "adds active responder to `responder` options" do
        expect(Releaf::Core::Responders::AfterSaveResponder).to receive(:call)
        subject.respond_with(nil)
      end
    end

    context "when responder is defined within options" do
      it "adds active responder to `responder` options" do
        expect(Releaf::Core::Responders::AfterSaveResponder).to_not receive(:call)
        expect(Releaf::Core::Responders::PageNotFoundResponder).to receive(:call)
        subject.respond_with(nil, responder: Releaf::Core::Responders::PageNotFoundResponder)
      end
    end
  end

  describe "#action_responders" do
    it "returns hash with action to responders matching" do
      hash = {
        create: Releaf::Core::Responders::AfterSaveResponder,
        update: Releaf::Core::Responders::AfterSaveResponder,
        confirm_destroy: Releaf::Core::Responders::ConfirmDestroyResponder,
        destroy: Releaf::Core::Responders::DestroyResponder,
        access_denied: Releaf::Core::Responders::AccessDeniedResponder,
        feature_disabled: Releaf::Core::Responders::FeatureDisabledResponder,
        page_not_found: Releaf::Core::Responders::PageNotFoundResponder,
      }
      expect(subject.action_responders).to eq(hash)
    end
  end

  describe "#action_responder" do
    it "returns matching responder for given action" do
      allow(subject).to receive(:action_responders).and_return(a: "x")
      expect(subject.action_responder(:a)).to eq("x")
      allow(subject).to receive(:action_responders).and_return(b: "x")
      expect(subject.action_responder(:a)).to be nil
    end
  end

  describe "#active_responder" do
    it "returns currect action matching responder" do
      allow(subject).to receive(:action_name).and_return(:save)
      allow(subject).to receive(:action_responder).with(:save).and_return("x")
      expect(subject.active_responder).to eq("x")
    end
  end
end
