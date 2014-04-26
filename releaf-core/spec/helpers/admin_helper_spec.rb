require 'spec_helper'

describe Releaf::AdminHelper do

  describe "#current_admin_user" do
    login_as_admin :admin
    it "returns current admin user" do
      expect( helper.current_admin_user ).to eq(Releaf::Admin.last)
    end
  end

  describe "#get_releaf_menu_item" do
    before do
       @input = {:controller=>"releaf/content", :url_helper=>"releaf_nodes_path", :name => "releaf/content", :icon => "cog"}
       @output = {:icon=>"cog", :name=>"releaf/content", :url=>"/admin/content", :active=>false}
    end

    it "returns menu hash for content controller hash" do
      expect( helper.get_releaf_menu_item(@input) ).to eq(@output)
    end

    context "when controller in params is same as given" do
      it "returns menu hash with :active value set to true" do
        @output[:active] = true
        helper.params[:controller] = "releaf/content"
        expect( helper.get_releaf_menu_item(@input) ).to eq(@output)
      end
    end
  end

  describe "#admin_menu" do
    context "when authorized as :admin user" do
      login_as_admin :admin
      it "returns all available controllers in menu" do
        output = [
          {:icon=>"file-text-o", :name=>"releaf/content", :url=>"/admin/content", :active=>false},
          {:name=>"inventory", :icon=>"briefcase", :collapsed=>false, :active=>false, :url=>"/admin/books",
           :items=>[
             {:icon=>nil, :name=>"admin/books", :url=>"/admin/books", :active=>false},
             {:icon=>nil, :name=>"admin/authors", :url=>"/admin/authors", :active=>false}]},
          {:name=>"permissions", :icon=>"user", :collapsed=>false, :active=>false, :url=>"/admin/admins",
           :items=>[
             {:icon=>nil, :name=>"releaf/admins", :url=>"/admin/admins", :active=>false},
             {:icon=>nil, :name=>"releaf/roles", :url=>"/admin/roles", :active=>false}]},
          {:icon=>"group", :name=>"releaf/translations", :url=>"/admin/translations", :active=>false}]
        expect( helper.admin_menu ).to eq(output)
      end
    end

    context "when authorized as :content_admin user" do
      login_as_admin :content_admin
      it "returns only content controller in menu" do
        output = [{:icon=>"file-text-o", :name=>"releaf/content", :url=>"/admin/content", :active=>false}]
        expect( helper.admin_menu ).to eq(output)
      end
    end
  end
end
