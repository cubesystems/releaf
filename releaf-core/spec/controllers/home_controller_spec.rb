require 'spec_helper'

describe Releaf::HomeController do

  describe "GET index" do
    context "when authorized as admin" do
      login_as_admin :admin

      it "redirects to admins controller" do
        get :index
        expect(response).to redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_admin.role.default_controller, :only_path => true))
      end
    end

    context "when authorized as content admin" do
      login_as_admin :admin

      it "redirects to content controller" do
        get :index
        expect(response).to redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_admin.role.default_controller, :only_path => true))
      end
    end
  end
end
