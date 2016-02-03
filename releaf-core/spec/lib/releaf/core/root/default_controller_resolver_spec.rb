require "rails_helper"

describe Releaf::Core::Root::DefaultControllerResolver do
  subject{ described_class.new(current_controller: Releaf::Core::RootController.new) }
  it_behaves_like "an Releaf::Core::Service includer"

  describe "#call" do
    it "iterates through each controllers and return first matching index path" do
      allow(subject).to receive(:controllers).and_return(["a", "b", "c"])
      allow(subject).to receive(:controller_index_path).with("a").and_return(nil)
      allow(subject).to receive(:controller_index_path).with("b").and_return("bb")
      expect(subject).to_not receive(:controller_index_path).with("c")
      expect(subject.call).to eq("bb")
    end
  end

  describe "#controller_index_path" do
    context "when controller has index action" do
      it "returns index path" do
        expect(subject.controller_index_path("admin/books")).to eq("/admin/books")
      end
    end

    context "when controller has no index action (ActionController::UrlGenerationError raised)" do
      it "returns nil" do
        url_helpers = Rails.application.routes.url_helpers
        allow(Rails.application.routes).to receive(:url_helpers).and_return(url_helpers)
        allow(url_helpers).to receive(:url_for)
          .with(action: "index", controller: "adsasdks", only_path: true).and_raise(ActionController::UrlGenerationError)
        expect(subject.controller_index_path("adsasdks")).to be nil
      end
    end

    context "when any other exception raised" do
      it "does not rescue from it" do
        url_helpers = Rails.application.routes.url_helpers
        allow(Rails.application.routes).to receive(:url_helpers).and_return(url_helpers)
        allow(url_helpers).to receive(:url_for)
          .with(action: "index", controller: "adsasdks", only_path: true).and_raise(ArgumentError, "xx")
        expect{ subject.controller_index_path("adsasdks") }.to raise_error(ArgumentError, "xx")
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
