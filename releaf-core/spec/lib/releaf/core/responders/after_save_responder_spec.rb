require "rails_helper"

describe Releaf::Core::Responders::AfterSaveResponder, type: :controller do
  let(:controller){ Releaf::BaseController.new }
  let(:resource){ Book.new}
  subject{ described_class.new(controller, [resource]) }

  describe "#json_resource_errors" do
    it "returns resource errors formatted with `Releaf::Releaf::ErrorFormatter`" do
      allow(Releaf::Core::ErrorFormatter).to receive(:format_errors).with(resource).and_return(a: "b")
      expect(subject.json_resource_errors).to eq(errors: {a: "b"})
    end
  end

  describe "#render_notification?" do
    before do
      allow(subject).to receive(:has_errors?).and_return(true)
      allow(subject).to receive(:format).and_return(:json)
    end

    context "when request format is other json" do
      it "returns true" do
        allow(subject).to receive(:format).and_return(:html)
        expect(subject.render_notification?).to be true
      end
    end

    context "when object has no errors" do
      it "returns true" do
        allow(subject).to receive(:has_errors?).and_return(false)
        expect(subject.render_notification?).to be true
      end
    end

    context "when request format is json and object has errors" do
      it "returns false" do
        expect(subject.render_notification?).to be false
      end
    end
  end

  describe "#respond" do
    before do
      allow(subject).to receive(:to_html)
    end

    context "when render notifications return `true`" do
      it "renders notification with success value true/false whether resource has errors" do
        allow(subject).to receive(:render_notification?).and_return(true)
        allow(subject).to receive(:has_errors?).and_return(true)
        expect(subject.controller).to receive(:render_notification).with(false)
        subject.respond

        allow(subject).to receive(:has_errors?).and_return(false)
        expect(subject.controller).to receive(:render_notification).with(true)
        subject.respond
      end
    end

    context "when render notifications return `false`" do
      it "does not render notification" do
        allow(subject).to receive(:render_notification?).and_return(false)
        expect(subject.controller).to_not receive(:render_notification)
        subject.respond
      end
    end
  end

  describe "#to_json" do
    context "when resource has errors" do
      it "calls `display_errors`" do
        allow(subject).to receive(:has_errors?).and_return(true)
        expect(subject).to receive(:display_errors)
        subject.to_json
      end
    end

    context "when resource has no errors" do
      before do
        allow(subject).to receive(:resource_location).and_return("some_url")
        allow(subject).to receive(:has_errors?).and_return(false)
      end

      context "when options has :redirect key" do
        it "calls `display_errors`" do
          allow(subject).to receive(:options).and_return(redirect: true)
          expect(subject).to receive(:render).with(json: {url: "some_url"}, status: 303)
          subject.to_json
        end
      end

      context "when options has key :destroyable with `false` value" do
        it "renders `refused_destroy` template" do
          allow(subject).to receive(:options).and_return({})
          expect(subject).to receive(:redirect_to).with("some_url", status: 303)
          subject.to_json
        end
      end
    end
  end
end

