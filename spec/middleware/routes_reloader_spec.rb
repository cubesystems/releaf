require "spec_helper"

describe Releaf::RoutesReloader do
  let(:app) { ->(env) { [200, env, "app"] } }

  let :request do
    Releaf::RoutesReloader.new(app).call(Rack::MockRequest.env_for('http://example.com'))
  end

  describe "on application startup" do
    it "sets routes loading time" do
      expect(Releaf::RoutesReloader.routes_loaded).to_not be_nil
    end
  end

  describe "on each request" do
    it "compares latest updates" do
      expect(Releaf::RoutesReloader).to receive(:reload_if_expired)
      request
    end
  end

  describe ".reload_if_expired" do
    context "when no nodes exists" do
      it "does not reload routes" do
        Releaf::Node.stub(:updated_at).and_return(nil)
        expect(Rails.application).to_not receive(:reload_routes!)
        Releaf::RoutesReloader.reload_if_expired
      end
    end

    context "when routes is up to date" do
      it "does not reload routes" do
        Releaf::Node.stub(:updated_at).and_return(Time.parse("1991-01-01"))
        expect(Rails.application).to_not receive(:reload_routes!)
        Releaf::RoutesReloader.reload_if_expired
      end
    end

    context "when routes is outdated" do
      it "reloads routes" do
        Releaf::Node.stub(:updated_at).and_return(Time.now)
        expect(Rails.application).to receive(:reload_routes!)
        Releaf::RoutesReloader.reload_if_expired
      end
    end
  end
end
