require 'spec_helper'

describe Releaf::AdminHelper do

  describe "#current_admin_user" do
    login_as_admin :admin
    it "returns current admin user" do
      expect( helper.current_admin_user ).to eq(Releaf::Admin.last)
    end
  end

  describe "#admin_breadcrumbs" do
    login_as_admin :admin

    context "with no controller defined in params" do
      it "returns just home url" do
        output = [
          {:name=>"Home", :url=>"/admin"}
        ]
        expect( helper.admin_breadcrumbs ).to eq(output)
      end
    end

    context "with controller defined in params" do
      before do
        @resource = Struct.new(:id, :to_s)
        @resource.stub(:new_record?) { false }
      end

      it "returns admin controller as last breadcrumb" do
        helper.params[:controller] = "releaf/admins"
        output = [
          {:name => "Home", :url => "/admin"},
          {:name => "Permissions", :url => "/admin/admins"},
          {:name => "Releaf/admins", :url => "/admin/admins"}
        ]
        expect( helper.admin_breadcrumbs ).to eq(output)
      end

      it 'returns model #to_text as last breadcrumb name when model respond to #to_text' do
        @resource.stub(:to_text){ "my name" }
        helper.params[:controller] = "releaf/admins"
        output = [
          {:name => "Home", :url => "/admin"},
          {:name => "Permissions", :url => "/admin/admins"},
          {:name => "Releaf/admins", :url => "/admin/admins"},
          {:name => @resource.to_text}
        ]
        expect( helper.admin_breadcrumbs(@resource) ).to eq(output)
      end

      it 'returns "new record" as last breadcrumb name when model is new record' do
        @resource.stub(:new_record?) { true }
        helper.params[:controller] = "releaf/admins"
        output = [
          {:name => "Home", :url => "/admin"},
          {:name => "Permissions", :url => "/admin/admins"},
          {:name => "Releaf/admins", :url => "/admin/admins"},
          {:name => "New record"}
        ]
        expect( helper.admin_breadcrumbs(@resource) ).to eq(output)
      end

      it 'returns "edit record" as last breadcrumb name when model do not respond to #to_text method' do
        helper.params[:controller] = "releaf/admins"
        output = [
          {:name => "Home", :url => "/admin"},
          {:name => "Permissions", :url => "/admin/admins"},
          {:name => "Releaf/admins", :url => "/admin/admins"},
          {:name => "Edit record"}
        ]
        expect( helper.admin_breadcrumbs(@resource) ).to eq(output)
      end
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
          {:icon=>"file-text-alt", :name=>"releaf/content", :url=>"/admin/content", :active=>false},
          {:name=>"inventory", :icon=>"briefcase", :collapsed=>true, :active=>false, :url=>"/admin/books",
           :items=>[
             {:icon=>nil, :name=>"admin/books", :url=>"/admin/books", :active=>false},
             {:icon=>nil, :name=>"admin/authors", :url=>"/admin/authors", :active=>false}]},
          {:name=>"permissions", :icon=>"user", :collapsed=>true, :active=>false, :url=>"/admin/admins",
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
        output = [{:icon=>"file-text-alt", :name=>"releaf/content", :url=>"/admin/content", :active=>false}]
        expect( helper.admin_menu ).to eq(output)
      end
    end
  end
end
