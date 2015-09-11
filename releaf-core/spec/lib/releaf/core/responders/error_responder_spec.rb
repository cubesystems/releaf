require "spec_helper"

describe Releaf::Core::Responders::ErrorResponder, type: :controller do
  class Releaf::Core::Responders::DummyErrorResponder < ActionController::Responder
    include Releaf::Core::Responders::ErrorResponder
    def status_code
      401
    end
  end

  controller{}
  subject{ Releaf::Core::Responders::DummyErrorResponder.new(controller, []) }

  describe "#template" do
    it "returns template based on class name" do
      expect(subject.template).to eq("dummy_error")
    end
  end

  describe "#to_html" do
    it "renders error template with class status code" do
      expect(subject).to receive(:render).with("releaf/error_pages/dummy_error", status: 401)
      subject.to_html
    end
  end
end
