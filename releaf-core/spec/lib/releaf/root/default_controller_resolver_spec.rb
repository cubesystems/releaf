require "rails_helper"

describe Releaf::Root::DefaultControllerResolver do
  let(:controller) { Releaf::RootController.new }
  #let(:request) { instance_double(ActionDispatch::Request) }
  subject { described_class.new(current_controller: controller) }

  #before do
    #allow( controller ).to receive(:request).and_return(request)
  #end

  it_behaves_like "an Releaf::Service includer"

  describe "#call" do
    it "returns first available controller definition path" do
      controller_a_definition = Releaf::ControllerDefinition.new("a")
      controller_b_definition = Releaf::ControllerDefinition.new("b")
      allow(controller_a_definition).to receive(:path).and_return("aa_path")
      allow(controller_b_definition).to receive(:path).and_return("bb_path")

      allow(Releaf.application.config).to receive(:controllers).and_return(
        "a" => controller_a_definition,
        "b" => controller_b_definition,
      )
      allow(subject).to receive(:controllers).and_return(["a", "b"])

      expect(subject.call).to eq("aa_path")
    end

    context "when no controller path is available" do
      it "returns nil" do
        allow(subject).to receive(:controllers).and_return([])
        expect(subject.call).to be nil
      end
    end
  end

  describe "#controllers" do
    it "returns available controllers from Releaf config" do
      allow(Releaf.application.config).to receive(:available_controllers).and_return("x")
      expect(subject.controllers).to eq("x")
    end
  end
end
