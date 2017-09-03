require "rails_helper"

describe Releaf::Content do
  let(:configuration){ Releaf::Content::Configuration.new(resources: {}) }

  describe ".configure_component" do
    it "adds new `Releaf::Content::Configuration` configuration with default resources" do
      allow(Releaf::Content::Configuration).to receive(:new)
        .with(resources: { 'Node' => { controller: 'Releaf::Content::NodesController' } }).and_return("_new")
      expect(Releaf.application.config).to receive(:add_configuration).with("_new")
      described_class.configure_component
    end
  end

  describe ".configuration" do
    it "returns a configuration instance" do
      expect(Releaf.application.config).to receive(:content).and_return(:ok)
      expect(described_class.configuration).to eq :ok
    end
  end

  [ :resources, :models, :default_model, :controllers, :routing ].each do |method|
    describe ".#{method}" do
      it "returns the method result from the configuration instance" do
        allow(described_class).to receive(:configuration).and_return(configuration)
        allow(configuration).to receive(method).and_return(:ok)
        expect(described_class.send(method)).to eq :ok
      end
    end
  end

  describe ".draw_component_routes", type: :routing do
    before do
      allow(described_class).to receive(:configuration).and_return(configuration)
      allow(configuration).to receive(:resources).and_return(
        'Node' => { controller: 'Releaf::Content::NodesController' },
        'OtherSite::OtherNode' => { controller: 'Admin::OtherSite::OtherNodesController' }
      )
      Dummy::Application.reload_routes!
    end

    after(:all) do
      Dummy::Application.reload_routes!
    end

    context "draws named admin routes for all defined content node controllers" do

      it "draws #index route" do
        expect( releaf_content_nodes_path ).to eq "/admin/nodes"
        expect( admin_other_site_other_nodes_path ).to eq "/admin/other_nodes"
        expect(get: "/admin/nodes").to route_to("releaf/content/nodes#index")
        expect(get: "/admin/other_nodes").to route_to("admin/other_site/other_nodes#index")
      end

      it "draws #new route" do
        expect( new_releaf_content_node_path ).to eq "/admin/nodes/new"
        expect( new_admin_other_site_other_node_path ).to eq "/admin/other_nodes/new"
        expect(get: "/admin/nodes/new").to route_to("releaf/content/nodes#new")
        expect(get: "/admin/other_nodes/new").to route_to("admin/other_site/other_nodes#new")
      end

      it "draws #create route" do
        expect(post: "/admin/nodes").to route_to("releaf/content/nodes#create")
        expect(post: "/admin/other_nodes").to route_to("admin/other_site/other_nodes#create")
      end

      it "draws #content_type_dialog route" do
        expect( content_type_dialog_releaf_content_nodes_path ).to eq "/admin/nodes/content_type_dialog"
        expect( content_type_dialog_admin_other_site_other_nodes_path ).to eq "/admin/other_nodes/content_type_dialog"
        expect(get: "/admin/nodes/content_type_dialog").to route_to("releaf/content/nodes#content_type_dialog")
        expect(get: "/admin/other_nodes/content_type_dialog").to route_to("admin/other_site/other_nodes#content_type_dialog")
      end

      it "draws #generate_url route" do
        expect( generate_url_releaf_content_nodes_path ).to eq "/admin/nodes/generate_url"
        expect( generate_url_admin_other_site_other_nodes_path ).to eq "/admin/other_nodes/generate_url"
        expect(get: "/admin/nodes/generate_url").to route_to("releaf/content/nodes#generate_url")
        expect(get: "/admin/other_nodes/generate_url").to route_to("admin/other_site/other_nodes#generate_url")
      end

      it "draws #edit route" do
        expect( edit_releaf_content_node_path(1) ).to eq "/admin/nodes/1/edit"
        expect( edit_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/edit"
        expect(get: "/admin/nodes/1/edit").to route_to("releaf/content/nodes#edit", "id" => "1")
        expect(get: "/admin/other_nodes/1/edit").to route_to("admin/other_site/other_nodes#edit", "id" => "1")
      end

      it "draws #update route" do
        expect(patch: "/admin/nodes/1").to route_to("releaf/content/nodes#update", "id" => "1")
        expect(patch: "/admin/other_nodes/1").to route_to("admin/other_site/other_nodes#update", "id" => "1")
      end

      it "draws #copy_dialog route" do
        expect( copy_dialog_releaf_content_node_path(1) ).to eq "/admin/nodes/1/copy_dialog"
        expect( copy_dialog_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/copy_dialog"
        expect(get: "/admin/nodes/1/copy_dialog").to route_to("releaf/content/nodes#copy_dialog", "id" => "1")
        expect(get: "/admin/other_nodes/1/copy_dialog").to route_to("admin/other_site/other_nodes#copy_dialog", "id" => "1")
      end

      it "draws #copy route" do
        expect( copy_releaf_content_node_path(1) ).to eq "/admin/nodes/1/copy"
        expect( copy_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/copy"
        expect(post: "/admin/nodes/1/copy").to route_to("releaf/content/nodes#copy", "id" => "1")
        expect(post: "/admin/other_nodes/1/copy").to route_to("admin/other_site/other_nodes#copy", "id" => "1")
      end

      it "draws #move_dialog route" do
        expect( move_dialog_releaf_content_node_path(1) ).to eq "/admin/nodes/1/move_dialog"
        expect( move_dialog_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/move_dialog"
        expect(get: "/admin/nodes/1/move_dialog").to route_to("releaf/content/nodes#move_dialog", "id" => "1")
        expect(get: "/admin/other_nodes/1/move_dialog").to route_to("admin/other_site/other_nodes#move_dialog", "id" => "1")
      end

      it "draws #move route" do
        expect( move_releaf_content_node_path(1) ).to eq "/admin/nodes/1/move"
        expect( move_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/move"
        expect(post: "/admin/nodes/1/move").to route_to("releaf/content/nodes#move", "id" => "1")
        expect(post: "/admin/other_nodes/1/move").to route_to("admin/other_site/other_nodes#move", "id" => "1")
      end

      it "draws #toolbox route" do
        expect( toolbox_releaf_content_node_path(1) ).to eq "/admin/nodes/1/toolbox"
        expect( toolbox_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/toolbox"
        expect(get: "/admin/nodes/1/toolbox").to route_to("releaf/content/nodes#toolbox", "id" => "1")
        expect(get: "/admin/other_nodes/1/toolbox").to route_to("admin/other_site/other_nodes#toolbox", "id" => "1")
      end

      it "draws #confirm_destroy route" do
        expect( confirm_destroy_releaf_content_node_path(1) ).to eq "/admin/nodes/1/confirm_destroy"
        expect( confirm_destroy_admin_other_site_other_node_path(1) ).to eq "/admin/other_nodes/1/confirm_destroy"
        expect(get: "/admin/nodes/1/confirm_destroy").to route_to("releaf/content/nodes#confirm_destroy", "id" => "1")
        expect(get: "/admin/other_nodes/1/confirm_destroy").to route_to("admin/other_site/other_nodes#confirm_destroy", "id" => "1")
      end

      it "draws #destroy route" do
        expect(delete: "/admin/nodes/1").to route_to("releaf/content/nodes#destroy", "id" => "1")
        expect(delete: "/admin/other_nodes/1").to route_to("admin/other_site/other_nodes#destroy", "id" => "1")
      end

      it "does not draw #show route" do
        expect(get: "/admin/nodes/1").to route_to("releaf/root#page_not_found", "path" => "nodes/1")
        expect(get: "/admin/other_nodes/1").to route_to("releaf/root#page_not_found", "path" => "other_nodes/1")
      end

    end

  end

end
