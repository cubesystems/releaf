require 'spec_helper'

describe Releaf::HomeController do

  describe "GET index" do
    context "when authorized as user" do
      login_as_user :user

      it "redirects to users controller" do
        get :index
        expect(response).to redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_permissions_user.role.default_controller, :only_path => true))
      end
    end

    context "when authorized as content user" do
      login_as_user :user

      it "redirects to content controller" do
        get :index
        expect(response).to redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_permissions_user.role.default_controller, :only_path => true))
      end
    end
  end
end
