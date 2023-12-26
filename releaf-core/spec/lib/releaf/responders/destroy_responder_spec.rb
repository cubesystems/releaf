require "rails_helper"

describe Releaf::Responders::DestroyResponder, type: :controller do
  let(:resource){ Book.new}
  subject{ described_class.new(Releaf::ActionController.new, [resource]) }

  describe "#to_html" do
    before do
      allow(subject.controller).to receive(:request).and_return(request)
      allow(subject.controller).to receive(:formats).and_return([:html])
      allow(subject).to receive(:default_render)
    end

    context "when resource has been successfully destroyed" do
      it "renders success notification" do
        resource.destroy
        expect(subject.controller).to receive(:render_notification).with(true, failure_message_key: "cant destroy, because relations exists")
        subject.to_html
      end
    end

    context "when resource has not been destroyed" do
      it "renders failure notification" do
        expect(subject.controller).to receive(:render_notification).with(false, failure_message_key: "cant destroy, because relations exists")
        subject.to_html
      end
    end
  end
end
