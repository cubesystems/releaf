require 'spec_helper'

describe Releaf::AdminHelper do

  describe "#get_releaf_menu_item" do
    it "returns hash with name, url and active values for given content controller hash" do
      input = {:controller=>"releaf/content", :helper=>"releaf_nodes"}
      output = {:active => false, :name => "releaf/content", :url => "/admin/content"}
      helper.get_releaf_menu_item(input).should eq(output)
    end

    it "returns hash with name, url and active values for given admins controller hash" do
      input = {:controller=>"releaf/admins"}
      output = {:active => true, :name => "releaf/admins", :url => "/admin/admins"}
      helper.params[:controller] = "releaf/admins"
      helper.get_releaf_menu_item(input).should eq(output)
    end
  end

  describe "#admin_main_menu for admin user" do
    login_as_admin :admin
    it "returns main menu" do
      output = [
        {:name=>"releaf/content", :url=>"/admin/content", :active=>false},
        {:name=>"permissions", :active=>false, :url=>"/admin/admins"},
        {:name=>"releaf/translations", :url=>"/admin/translations", :active=>false}
      ]
      helper.admin_main_menu.should eq(output)
    end
  end

  describe "#admin_main_menu for content admin user" do
    login_as_admin :content_admin
    it "returns main menu" do
      output = [{:name=>"releaf/content", :url=>"/admin/content", :active=>false}]
      helper.admin_main_menu.should eq(output)
    end
  end

end
