require "rails_helper"

describe Releaf::Responders::ConfirmDestroyResponder, type: :controller do
  let(:controller){ Releaf::ActionController.new }
  let(:resource){ Book.new}
  subject{ described_class.new(controller, [resource]) }

  describe "#to_html" do
    context "when options has key :destroyable with `true` value" do
      it "renders default view" do
        allow(subject).to receive(:options).and_return(destroyable: true)
        expect(subject).to receive(:default_render)
        subject.to_html
      end
    end

    context "when options has key :destroyable with `false` value" do
      it "renders `refused_destroy` template" do
        allow(subject).to receive(:options).and_return(destroyable: false)
        expect(subject).to receive(:render).with("refused_destroy")
        subject.to_html
      end
    end
  end
end

