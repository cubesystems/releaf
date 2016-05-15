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
    it "returns first available controller index path" do
      allow(subject).to receive(:controllers).and_return(["a", "b", "c"])
      allow(subject).to receive(:controller_index_path).with("a").and_return(nil)
      allow(subject).to receive(:controller_index_path).with("b").and_return("bb")
      allow(subject).to receive(:controller_index_path).with("c").and_return("cc")

      expect(subject.call).to eq("bb")
    end

    context "when no controller path is available" do
      it "returns nil" do
        allow(subject).to receive(:controllers).and_return(["a", "b"])
        allow(subject).to receive(:controller_index_path).with("a").and_return(nil)
        allow(subject).to receive(:controller_index_path).with("b").and_return(nil)

        expect(subject.call).to be nil
      end
    end
  end

  describe "#controller_index_path" do
    before do
      allow(subject).to receive(:route_path).with(controller: "x", action: "index")
        .and_return("_index_path_")
      allow(subject).to receive(:route_path).with(controller: "x", action: "index", subdomain: "shop")
        .and_return("_shop_index_path_")
    end

    context "when subdomain is not present" do
      it "returns index path for given controller" do
        allow(subject).to receive(:subdomain).and_return("")
        expect(subject.controller_index_path("x")).to eq("_index_path_")
      end
    end

    context "when subdomain is present" do
      before do
        allow(subject).to receive(:subdomain).and_return("shop")
      end

      context "when subdomain index exists" do
        it "returns subdomain index path for given controller" do
          expect(subject.controller_index_path("x")).to eq("_shop_index_path_")
        end
      end

      context "when subdomain index does not exist" do
        it "returns index path for given controller" do
          allow(subject).to receive(:route_path).with(controller: "x", action: "index", subdomain: "shop")
            .and_return(nil)
          expect(subject.controller_index_path("x")).to eq("_index_path_")
        end
      end
    end
  end

  describe "#route_path" do
    context "when route exists" do
      it "returns route path" do
        allow(subject).to receive(:route_exists?).with(controller: "admin/books", action: "index").and_return(true)
        expect(subject.route_path(controller: "admin/books", action: "index")).to eq("/admin/books")
      end
    end

    context "when given route does not exist" do
      it "returns nil" do
        allow(subject).to receive(:route_exists?).with(controller: "admin/books", action: "index").and_return(false)
        expect(subject.route_path(controller: "admin/books", action: "index")).to be nil
      end
    end
  end

  describe "#route_exists?" do
    context "when given route exists" do
      it "returns true" do
        expect(subject.route_exists?(controller: "admin/books", action: "index")).to be true
      end
    end

    context "when given route does not exist" do
      it "returns false" do
        expect(subject.route_exists?(controller: "releaf/permissions/profile", action: "index")).to be false
        expect(subject.route_exists?(controller: "admin/asdasd", action: "index")).to be false
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
