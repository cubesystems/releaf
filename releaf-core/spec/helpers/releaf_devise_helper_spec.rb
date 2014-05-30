require 'spec_helper'

describe Releaf::ReleafDeviseHelper do
   describe ".devise_admin_model_name" do
    it "returns undercored current devise admin model name" do
      Releaf::ReleafDeviseHelper.devise_admin_model_name.should eq("releaf_permissions_admin")
    end
  end
end
