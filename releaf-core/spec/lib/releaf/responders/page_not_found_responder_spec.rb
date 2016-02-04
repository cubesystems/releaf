require "rails_helper"

describe Releaf::Responders::PageNotFoundResponder, type: :controller do
  controller{}
  subject{ described_class.new(controller, []) }

  describe "#status_code" do
    it "returns 404" do
      expect(subject.status_code).to eq(404)
    end
  end
end
