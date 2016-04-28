require "rails_helper"

describe Releaf::Content::RoutesReloader do
  let(:app) { ->(env) { [200, env, "app"] } }

  let(:subject) { described_class.new(app) }
  let(:request_env) { Rack::MockRequest.env_for('http://example.com') }

  let :request do
    subject.call(request_env)
  end

  describe "on application startup" do
    it "sets routes loading time" do
      expect(subject.routes_loaded).to_not be_nil
    end
  end

  describe "on each request" do
    it "compares latest updates" do
      expect(subject).to receive(:reload_if_needed)
      request
    end
  end

  describe "#reload_if_needed" do

    context "when reload is needed" do
      it "reloads routes" do
        allow(subject).to receive(:needs_reload?).and_return true
        expect(Rails.application).to receive(:reload_routes!)
        subject.reload_if_needed
      end
    end

    context "when reload is not needed" do
      it "does not reload routes" do
        allow(subject).to receive(:needs_reload?).and_return false
        expect(Rails.application).to_not receive(:reload_routes!)
        subject.reload_if_needed
      end
    end

  end

  describe "#needs_reload?" do

    context "when no nodes exist" do
      it "returns false" do
        allow(Node).to receive(:updated_at).and_return(nil)
        expect(subject.needs_reload?).to be false
      end
    end

    context "when node routes are up to date" do
      it "returns false" do
        allow(Node).to receive(:updated_at).and_return(Time.parse("1991-01-01"))
        expect(subject.needs_reload?).to be false
      end
    end

    context "when node routes are outdated" do
      it "returns true" do
        allow(Node).to receive(:updated_at).and_return(Time.now + 1.minute)
        expect(subject.needs_reload?).to be true
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
      expect(subject.needs_reload?).to be true
    end

  end
end
