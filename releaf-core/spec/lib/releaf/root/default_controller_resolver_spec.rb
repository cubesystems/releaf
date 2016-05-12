require "rails_helper"

describe Releaf::Root::DefaultControllerResolver do
  let(:controller) { Releaf::RootController.new }
  let(:request) { instance_double(ActionDispatch::Request, subdomain: nil) }
  subject { described_class.new(current_controller: controller) }

  before do
    allow( controller ).to receive(:request).and_return(request)
  end

  it_behaves_like "an Releaf::Service includer"

  describe "#call" do
    it "iterates through each controllers and return first matching index path" do
      allow(subject).to receive(:controllers).and_return(["a", "b", "c"])
      allow(subject).to receive(:controller_index_exists?).with("a").and_return(false)
      allow(subject).to receive(:controller_index_exists?).with("b").and_return(true)
      allow(subject).to receive(:controller_index_path).with("b").and_return("bb")

      expect(subject).to_not receive(:controller_index_exists?).with("c")
      expect(subject.call).to eq("bb")
    end
  end

  describe "#controller_index_path" do
    it "returns index path for given controller" do
      expect(subject.controller_index_path("admin/books")).to eq("/admin/books")
    end
  end

  describe "#controller_index_exists?" do
    context "when controller has index action" do
      it "returns true" do
        expect(subject.controller_index_exists?("admin/books")).to be true
      end
    end

    context "when controller has no index action" do
      it "returns false" do
        expect(subject.controller_index_exists?("releaf/permissions/profile")).to be false
        expect(subject.controller_index_exists?("admin/asdasd")).to be false
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
