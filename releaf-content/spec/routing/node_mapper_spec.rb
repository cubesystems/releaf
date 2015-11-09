require "rails_helper"

describe Releaf::Content::NodeMapper do
  after(:all) do
    # reset dummy app routes
    Dummy::Application.reload_routes!
  end

  before do
    Dummy::Application.reload_routes!
    @text_page = FactoryGirl.create(:text_page)
    @lv_root = create(:home_page_node, name: "lv", locale: "lv", slug: 'lv')
    @node = FactoryGirl.create(:node, slug: 'test-page', content: @text_page, parent: @lv_root)
  end

  describe "#releaf_routes_for" do

    describe "using current node path" do
      example "using default controller " do
        routes.draw do
          releaf_routes_for(TextPage) do |route|
            get 'show'
            delete :destroy
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "text_pages",
          "action" => "show",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )

        expect(delete: '/lv/test-page').to route_to(
          "controller" => "text_pages",
          "action" => "destroy",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end

      example "overriding default controller" do
        routes.draw do
          releaf_routes_for(TextPage, controller: 'home_pages') do |route|
            get 'show'
            delete :destroy
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "home_pages",
          "action" => "show",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end

      example "specifying different than default controller for route" do
        routes.draw do
          releaf_routes_for(TextPage, controller: 'doesnt_matter') do |route|
            get 'home_pages#hide'
          end
        end

        expect(get: '/lv/test-page').to route_to(
          "controller" => "home_pages",
          "action" => "hide",
          "node_id" => @node.id.to_s,
          "locale" => 'lv'
        )
      end
    end

    describe "adding uri parts to node path" do
      example "speciffying custom controller and action" do
        routes.draw do
          releaf_routes_for(TextPage) do |route|
            get ':my_id/list', to: 'home_pages#list'
          end
        end

        expect(get: '/lv/test-page/8888/list').to route_to(
          "controller" => "home_pages",
          "action" => "list",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "my_id" => '8888'
        )
      end

      example "speciffying action" do
        routes.draw do
          releaf_routes_for(TextPage) do |route|
            get ':my_id/list', to: '#list'
          end
        end

        expect(get: '/lv/test-page/8888/list').to route_to(
          "controller" => "text_pages",
          "action" => "list",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "my_id" => '8888'
        )
      end

      example "speciffying action and overriding default controller" do
        routes.draw do
          releaf_routes_for(TextPage, controller: 'home_pages') do |route|
            get ':my_id/list', to: '#list'
          end
        end

        expect(get: '/lv/test-page/8888/list').to route_to(
          "controller" => "home_pages",
          "action" => "list",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "my_id" => '8888'
        )
      end

      example "speciffying custom path" do
        routes.draw do
          releaf_routes_for(TextPage) do |route|
            get 'home_pages#show', path: "#{route.path}/abc/:my_id"
          end
        end

        expect(get: '/lv/test-page/abc/333').to route_to(
          "controller" => "home_pages",
          "action" => "show",
          "node_id" => @node.id.to_s,
          "locale" => 'lv',
          "my_id" => '333'
        )
      end

    end

  end
end
