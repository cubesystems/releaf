require "rails_helper"

describe Releaf::Responders::ErrorResponder, type: :controller do
  class Releaf::Responders::DummyErrorResponder < ActionController::Responder
    include Releaf::Responders::ErrorResponder
    def status_code
      401
    end
  end

  controller{}
  subject{ Releaf::Responders::DummyErrorResponder.new(controller, []) }

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
