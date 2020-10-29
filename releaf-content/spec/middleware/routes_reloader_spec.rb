require "rails_helper"

describe Releaf::Content::RoutesReloader do
  let(:app) { ->(env) { [200, env, "app"] } }

  let :request do
    described_class.new(app).call(Rack::MockRequest.env_for('http://example.com'))
  end

  describe "on application startup" do
    it "sets routes loading time" do
      expect(described_class.routes_loaded).to_not be_nil
    end
  end

  describe "on each request" do
    it "compares latest updates" do
      expect(described_class).to receive(:reload_if_needed)
      request
    end
  end

  describe ".reset!" do

    it "changes class @updated_at instance to nil" do
      described_class.instance_variable_set(:@updated_at, "x")
      expect{ described_class.reset! }.to change{ described_class.instance_variable_get(:@updated_at) }.to(nil)
    end

  end

  describe ".reload_if_needed" do

    context "when reload is needed" do
      it "reloads routes" do
        allow(described_class).to receive(:needs_reload?).and_return true
        expect(Rails.application).to receive(:reload_routes!)
        described_class.reload_if_needed
      end
    end

    context "when reload is not needed" do
      it "does not reload routes" do
        allow(described_class).to receive(:needs_reload?).and_return false
        expect(Rails.application).to_not receive(:reload_routes!)
        described_class.reload_if_needed
      end
    end

  end

  describe ".needs_reload?" do

    context "when no nodes exist" do
      it "returns false" do
        allow(Node).to receive(:updated_at).and_return(nil)
        expect(described_class.needs_reload?).to be false
      end
    end

    context "when node routes has not been loaded" do
      it "returns true" do
        described_class.instance_variable_set(:@updated_at, nil)
        allow(Node).to receive(:updated_at).and_return(Time.parse("1991-01-01"))
        expect(described_class.needs_reload?).to be true
      end
    end

    context "when node routes are up to date" do
      it "returns false" do
        described_class.instance_variable_set(:@updated_at, Time.parse("1991-01-01"))
        allow(Node).to receive(:updated_at).and_return(Time.parse("1991-01-01"))
        expect(described_class.needs_reload?).to be false
      end
    end

    context "when node routes are outdated" do
      it "returns true" do
        allow(Node).to receive(:updated_at).and_return(Time.now + 1.minute)
        expect(described_class.needs_reload?).to be true
      end
    end

    it "checks all content model classes" do
      class RouteReloaderDummyNode
        def self.updated_at
          Time.now + 1.minute
        end
      end
      allow(Releaf::Content).to receive(:models).and_return [ Node, RouteReloaderDummyNode ]
      allow(Node).to receive(:updated_at).and_return(nil)
      expect(described_class.needs_reload?).to be true
    end

  end
end
