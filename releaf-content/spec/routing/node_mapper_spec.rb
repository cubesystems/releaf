require "rails_helper"

describe Releaf::Content::NodeMapper do

  let(:multiple_node_resources) {{
    'Node' => {
      controller: 'Releaf::Content::NodesController',
      routing: { site: "main_site", constraints: { host: /^releaf\.local$/ } }
    },
    'OtherSite::OtherNode' => {
      controller: 'Admin::OtherSite::OtherNodesController',
      routing: { site: "other_site", constraints: { host: /^other\.releaf\.local$/ } }
    }
  }}

  before do
    @text_page = create(:text_page)
    @lv_root_node = create(:home_page_node, name: "lv", locale: "lv", slug: 'lv')
    @node = create(:node, slug: 'test-page', content: @text_page, parent: @lv_root_node)
  end

  before with_multiple_node_classes: true do
    allow( Releaf.application.config ).to receive(:content).and_return(
      Releaf::Content::Configuration.new(resources: multiple_node_resources)
    )
    @other_text_page = create(:text_page)
    @other_lv_root_node = create(:other_home_page_node, name: "lv", locale: "lv", slug: 'lv')
    @other_node = create(:other_node, slug: 'test-page', content: @other_text_page, parent: @other_lv_root_node)
  end

  after do
    Dummy::Application.reload_routes!
  end

  after(:all) do
    # without this the test environent remains polluted with test node class config.
    # the routing configuration gets already reset after each test in the after block above
    # but that seems to not be enough
    Dummy::Application.reload_routes!
  end

  describe "#node_routes_for", create_nodes: true do

    it "draws public website routes for default node class" do

      routes.draw do
        node_routes_for(TextPage) do |route|
          get 'show'
          delete :destroy
        end
      end

      expect(get: '/lv/test-page').to route_to(
        "controller" => "text_pages",
        "action" => "show",
        "node_class" => "Node",
        "node_id" => @node.id.to_s,
        "locale" => 'lv'
      )

      expect(delete: '/lv/test-page').to route_to(
        "controller" => "text_pages",
        "action" => "destroy",
        "node_class" => "Node",
        "node_id" => @node.id.to_s,
        "locale" => 'lv'
      )
    end

    context "when a controller is given in arguments" do

      it "draws the public website route to given controller" do
        routes.draw do
          node_routes_for(TextPage, controller: 'home_pages') do |route|
            get 'show'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "home_pages",
          "action" => "show",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end

    end

    context "when a controller is passed in route options" do
      it "draws the public website route using the controller from options" do
        routes.draw do
          node_routes_for(TextPage, controller: 'doesnt_matter') do |route|
            get 'home_pages#hide'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "home_pages",
          "action" => "hide",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end
    end

    context "when custom action is given in :to" do
      it "draws the public website route using the action from :to" do
        routes.draw do
          node_routes_for(TextPage) do |route|
            get '' , to: '#list'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "text_pages",
          "action" => "list",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )

      end
    end

    context "when custom controller and action are given in :to" do
      it "draws the public website route using the given controller and action from :to" do
        routes.draw do
          node_routes_for(TextPage) do |route|
            get '' , to: 'home_pages#list'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "home_pages",
          "action" => "list",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end
    end

    context "when additional params are given in route path" do
      it "passes the params to the public website route" do
        routes.draw do
          node_routes_for(TextPage) do |route|
            get ':some_id', to: "#view"
          end
        end

        expect(get: '/lv/test-page/8888').to route_to(
          "controller" => "text_pages",
          "action" => "view",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "some_id" => '8888'
        )
      end
    end

    context "when custom path is given for route" do
      it "uses the custom path for public website route" do
        routes.draw do
          node_routes_for(TextPage) do |route|
            get 'home_pages#show', path: "#{route.path}/abc/:my_id"
          end
        end

        expect(get: '/lv/test-page/abc/333').to route_to(
          "controller" => "home_pages",
          "action" => "show",
          "node_class" => "Node",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "my_id" => '333'
        )
      end
    end

    context "when custom node class is given as an argument", with_multiple_node_classes: true do

      it "uses that node class for the public website route" do
        routes.draw do
          node_routes_for(TextPage, node_class: "OtherSite::OtherNode") do |route|
            get 'show'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "text_pages",
          "action" => "show",
          "node_class" => "OtherSite::OtherNode",
          "node_id" => @other_node.id.to_s,
          "locale" => 'lv',
          "site"   => 'other_site'
        )
      end

    end

  end

  describe "#for_node_class", with_multiple_node_classes: true do

    it "uses given node class as a default when drawing public website routes in the given block" do
      routes.draw do
        for_node_class "OtherSite::OtherNode" do
          node_routes_for(TextPage) do |route|
            get 'show'
          end
        end
      end

      expect(get: '/lv/test-page').to route_to(
        "controller" => "text_pages",
        "action" => "show",
        "node_class" => "OtherSite::OtherNode",
        "node_id" => @other_node.id.to_s,
        "locale" => 'lv',
        "site"   => 'other_site'
      )
    end

    it "restores default node class after block has been executed" do
      routes.draw do
        for_node_class "OtherSite::OtherNode" do
          node_routes_for(TextPage) do |route|
            get 'show'
          end
        end
        node_routes_for(HomePage) do |route|
            get 'show'
        end
      end

      expect(get: '/lv').to route_to(
        "controller" => "home_pages",
        "action" => "show",
        "node_class" => "Node",
        "node_id" => @lv_root_node.id.to_s,
        "locale" => 'lv',
        "site"   => 'main_site'
      )
    end

  end

  describe "#node_routing", with_multiple_node_classes: true do

    it "draws public website routes for all node classes in the given routing hash using respective route constraints" do

      routes.draw do
        node_routing( Releaf::Content.routing ) do
          node_routes_for(TextPage) do |route|
            get 'show'
          end
        end
      end

      expect(get: 'http://releaf.local/lv/test-page').to route_to(
        "controller" => "text_pages",
        "action" => "show",
        "node_class" => "Node",
        "node_id" => @node.id.to_s,
        "locale" => 'lv',
        "site"   => 'main_site'
      )

      expect(get: 'http://other.releaf.local/lv/test-page').to route_to(
        "controller" => "text_pages",
        "action" => "show",
        "node_class" => "OtherSite::OtherNode",
        "node_id" => @other_node.id.to_s,
        "locale" => 'lv',
        "site"   => 'other_site'
      )

    end

    context "when passed a routing hash for only a subset of available node classes" do
      it "draws constrained public website routes only for the given node classes" do
        routes.draw do
          routing_hash = Releaf::Content.routing.except('Node')
          node_routing( routing_hash ) do
            node_routes_for(TextPage) do |route|
              get 'show'
            end
          end
        end

        expect(get: 'http://other.releaf.local/lv/test-page').to route_to(
          "controller" => "text_pages",
          "action" => "show",
          "node_class" => "OtherSite::OtherNode",
          "node_id" => @other_node.id.to_s,
          "locale" => 'lv',
          "site"   => 'other_site'
        )

        expect(get: 'http://releaf.local/lv/test-page').to_not be_routable

      end
    end

  end

end
