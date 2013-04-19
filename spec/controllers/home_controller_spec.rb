require 'spec_helper'

describe Releaf::HomeController do

  describe "admin default redirect" do
    login_as_admin :admin
    it "should redirect to admins controller" do
      get 'index'
      response.should redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_admin.role.default_controller, :only_path => true))
    end
  end

  describe "content admin default redirect" do
    login_as_admin :content_admin
    it "should redirect to content controller" do
      get 'index'
      response.should redirect_to(url_for(:action => 'index', :controller => subject.current_releaf_admin.role.default_controller, :only_path => true))
    end
  end
end
