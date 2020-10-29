require "rails_helper"

describe Releaf::Responders::AfterSaveResponder, type: :controller do
  let(:controller){ Releaf::ActionController.new }
  let(:resource){ Book.new}
  subject{ described_class.new(controller, [resource]) }

  describe "#json_resource_errors" do
    it "returns resource errors hash built with `Releaf::BuildErrorsHash`" do
      allow(Releaf::BuildErrorsHash).to receive(:call).with(resource: resource, field_name_prefix: :resource)
        .and_return(a: "b")
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
      it "redirects to resource location with status code `303`" do
        allow(subject).to receive(:resource_location).and_return("some_url")
        allow(subject).to receive(:has_errors?).and_return(false)
        expect(subject).to receive(:redirect_to).with("some_url", status: 303, turbolinks: false)
        subject.to_json
      end
    end
  end
end
