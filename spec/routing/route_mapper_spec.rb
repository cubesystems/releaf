require "spec_helper"

describe Releaf::RouteMapper do
  describe "mount devise session controller" do
    it "calls #devise_for routing mapper method" do
      ActionDispatch::Routing::Mapper.any_instance.should_receive(:devise_for).
        with("releaf/admin", {path: "/my-admin", controllers: {sessions: "releaf/sessions"}, skip: [:passwords]})

      routes.draw do
        mount_releaf_at '/my-admin'
      end
    end
  end
end
