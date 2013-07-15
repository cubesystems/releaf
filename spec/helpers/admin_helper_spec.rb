require 'spec_helper'

describe Releaf::AdminHelper do

  describe "#get_releaf_menu_item" do
    it "returns hash with name, url and active values for given content controller hash" do
      input = {:controller=>"releaf/content", :url_helper=>"releaf_nodes_path", :name => "releaf/content", :icon => "cog"}
      output = {:icon=>"cog", :name=>"releaf/content", :url=>"/admin/content", :active=>false}
      helper.get_releaf_menu_item(input).should eq(output)
    end

    it "returns hash with name, url and active values for given admins controller hash" do
      input = {:controller=>"releaf/admins", :url_helper => "releaf_admins_path", :name => "releaf/admins", :icon => "cog" }
      output = {:icon=>"cog", :name=>"releaf/admins", :url=>"/admin/admins", :active=>true}
      helper.params[:controller] = "releaf/admins"
      helper.get_releaf_menu_item(input).should eq(output)
    end
  end

  describe "#admin_menu for admin user" do
    login_as_admin :admin
    it "returns main menu" do
      output = [
        {:icon=>"file-text-alt", :name=>"releaf/content", :url=>"/admin/content", :active=>false},
        {:name=>"inventory", :icon=>"briefcase", :collapsed=>nil, :active=>false, :url=>"/admin/books",
         :items=>[
           {:icon=>nil, :name=>"admin/books", :url=>"/admin/books", :active=>false},
           {:icon=>nil, :name=>"admin/authors", :url=>"/admin/authors", :active=>false}]},
        {:name=>"permissions", :icon=>"user", :collapsed=>nil, :active=>false, :url=>"/admin/admins",
         :items=>[
           {:icon=>nil, :name=>"releaf/admins", :url=>"/admin/admins", :active=>false},
           {:icon=>nil, :name=>"releaf/roles", :url=>"/admin/roles", :active=>false}]},
        {:icon=>"group", :name=>"releaf/translations", :url=>"/admin/translations", :active=>false}]
      helper.admin_menu.should eq(output)
    end
  end

  describe "#admin_menu for content admin user" do
    login_as_admin :content_admin
    it "returns main menu" do
      output = [{:icon=>"file-text-alt", :name=>"releaf/content", :url=>"/admin/content", :active=>false}]
      helper.admin_menu.should eq(output)
    end
  end

end
