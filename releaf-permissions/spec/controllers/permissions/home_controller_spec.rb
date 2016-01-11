require 'rails_helper'

describe Releaf::Permissions::HomeController do

  describe "GET home" do
    context "when authorized as user" do
      login_as_user :user

      before do
        @role = subject.current_releaf_permissions_user.role
      end

      it "redirects to users controller" do
        get :home
        expect(response).to redirect_to(url_for(action: 'index', controller: @role.default_controller, only_path: true))
      end

      context "when users default controller doesn't exist" do
        before do
          @role.update_attribute(:default_controller, 'non_existing/controllers_name')
        end

        it "redirects to first available controller" do
          get :home
          expect(response).to redirect_to(url_for(action: 'index', controller: "admin/nodes", only_path: true))
        end

        context "when no releaf controller is available" do
          before do
            @role.permissions = []
            @role.save!
          end

          it "redirects to root_path" do
            get :home
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    context "when authorized as content user" do
      login_as_user :user

      it "redirects to content controller" do
        get :home
        expect(response)
          .to redirect_to(url_for(action: 'index', controller: subject.current_releaf_permissions_user.role.default_controller, only_path: true))
      end
    end
  end
end
