require 'spec_helper'

describe Releaf::ReleafDeviseHelper do
   describe ".devise_admin_model_name" do
    it "returns undercored current devise admin model name" do
      expect(Releaf::ReleafDeviseHelper.devise_admin_model_name).to eq("releaf_permissions_user")
    end
  end
end
