require 'rails_helper'
describe "Nodes", js: true, with_tree: true, with_root: true do

  before do
    Rails.cache.clear
    # preload ActsAsNode classes
    Rails.application.eager_load!
  end


  before with_releaf_node_controller: true do
    # stub node config and admin menu to use default releaf node controller

    allow( Releaf.application.config).to receive(:content).and_return(Releaf::Content::Configuration.new(
      resources: { 'Node' => { controller: 'Releaf::Content::NodesController' } }
    ))

    # preserve default config because it will be needed in after block
    @default_menu_config = Releaf.application.config.menu.dup
    stubbed_menu_config = @default_menu_config.map do |item|
      if item[:controller] == 'admin/nodes'
        { :controller => 'releaf/content/nodes' }
      else
        item.dup
      end
    end
    allow( Releaf.application.config ).to receive(:menu).and_return( Releaf::Configuration.normalize_controllers(stubbed_menu_config) )
    # reset cached values
    Releaf.application.config.instance_variable_set(:@controllers, nil)
    Releaf.application.config.instance_variable_set(:@available_controllers, nil)

    Dummy::Application.reload_routes!
  end


  before with_multiple_node_classes: true do
    @default_port_inclusion_state = Capybara.always_include_port
    Capybara.always_include_port = true

    # stub node config and admin menu to use two node classes with separate controllers

    allow( Releaf.application.config).to receive(:content).and_return(Releaf::Content::Configuration.new(
      resources: {
        'Node' => {
          controller: 'Releaf::Content::NodesController',
          routing: { site: "main_site", constraints: { host: Regexp.new( "^" + Regexp.escape("releaf.127.0.0.1.xip.io") + "$" ) } }
        },
        'OtherSite::OtherNode' => {
         controller: 'Admin::OtherSite::OtherNodesController',
         routing: { site: "other_site", constraints: { host: Regexp.new( "^" + Regexp.escape("other.releaf.127.0.0.1.xip.io") + "$" ) } }
        }
      }
    ))

    # preserve default config because it will be needed in after block
    @default_menu_config = Releaf.application.config.menu.dup
    stubbed_menu_config = @default_menu_config.map do |item|
      if item[:controller] == 'admin/nodes'
        { :controller => 'releaf/content/nodes' }
      else
        item.dup
      end
    end
    content_index = stubbed_menu_config.index( { :controller => 'releaf/content/nodes' } )
    stubbed_menu_config.insert( content_index + 1,  { :controller => 'admin/other_site/other_nodes' } )

    allow( Releaf.application.config ).to receive(:menu).and_return( Releaf::Configuration.normalize_controllers(stubbed_menu_config) )
    # reset cached values
    Releaf.application.config.instance_variable_set(:@controllers, nil)
    Releaf.application.config.instance_variable_set(:@available_controllers, nil)

    Dummy::Application.reload_routes!
  end


  before do
    @user = auth_as_user
  end


  before with_root: true do
    @lv_root = create(:home_page_node, name: "lv", locale: "lv", slug: "lv")
  end


  before with_tree: true do
    @how_to = create(:text_page_node, parent_id: @lv_root.id)
    @about_us = create(:text_page_node, parent_id: @lv_root.id, name: "about us", slug: "about-us")
    @history_node = create(:text_page_node, parent_id: @about_us.id, name: "history")

    @en_root = create(:home_page_node, name: "en", locale: "en", slug: "en")
  end


  before with_tree: true do |example|
    if example.metadata[:with_releaf_node_controller].blank? && example.metadata[:with_multiple_node_classes].blank?
      visit admin_nodes_path
    end
  end


  before with_other_tree: true do
    @other_lv_root = create(:other_home_page_node, name: "Other lv", locale: "lv", slug: "lv")
    @other_about_us = create(:other_text_page_node, parent_id: @other_lv_root.id, name: "Other about us", slug: "about-us")
    @other_history  = create(:other_text_page_node, parent_id: @other_lv_root.id, name: "Other history", slug: "other-history")
  end


  after with_multiple_node_classes: true do
    Capybara.always_include_port = @default_port_inclusion_state
  end


  after do |example|

    if example.metadata[:with_releaf_node_controller].present? || example.metadata[:with_multiple_node_classes].present?
      allow( Releaf.application.config ).to receive(:content).and_call_original
      allow( Releaf.application.config ).to receive(:menu).and_return(@default_menu_config)

      # reset cached values
      Releaf.application.config.instance_variable_set(:@controllers, nil)
      Releaf.application.config.instance_variable_set(:@available_controllers, nil)
      Dummy::Application.reload_routes!
    end

  end

  after(:all) do
    Dummy::Application.reload_routes!
  end


  describe "new node" do

    context "when creating node under root" do
      it "creates new node in content tree" do
        @en_root.destroy
        click_link "Create new resource"
        click_link "Home page"
        expect(page).to have_css('.button',    text: 'Save')
        expect(page).to have_no_css('.button', text: 'Save and create another')
        create_resource do
          fill_in "resource_name", with: "en"
          select "en", from: "Locale"
        end

        expect(page).to have_breadcrumbs("Admin/nodes", "en")
      end
    end

    context "when creating node under another node" do
      it "creates new node" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .toolbox-cell button').click
        click_link "Add child"
        click_link "Contacts controller"
        expect(page).to have_css('.button',    text: 'Save')
        expect(page).to have_no_css('.button', text: 'Save and create another')
        create_resource do
          fill_in "resource_name", with: "Contacts"
        end

        expect(page).to have_breadcrumbs("Admin/nodes", "lv", "Contacts")
      end
    end
  end

  describe "tree collapsing" do
    context "when not opened before" do
      it "does not show node's children" do
        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"].collapsed')
      end
    end

    context "when clicked to uncollapse node" do
      it "shows node children" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps opened node children visibility permanent" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        wait_for_settings_update("content.tree.expanded.#{@lv_root.id}")
        visit admin_nodes_path

        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps closed node children visibility permanent" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        wait_for_settings_update("content.tree.expanded.#{@lv_root.id}", false)
        visit admin_nodes_path

        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_admin_node_path @en_root
    end

    context "when going to node from toolbox list" do
      it "navigates to targeted node's edit view" do
        expect(page).to have_no_header(text: 'lv')
        open_toolbox_dialog "Go to"

        click_link "lv"
        expect(page).to have_header(text: 'lv')
      end
    end
  end

  describe "copy node to" do
    context "when copying node" do
      it "shows copied node in tree" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @about_us.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")

        within_dialog do
          find('label > span', text: "en").click
          click_button "Copy"
        end

        expect(page).to have_notification("Copy succeeded")

        find('li[data-id="' + @en_root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "about us", count: 2)
      end
    end

    context "when copying node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @about_us.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")

        within_dialog do
          find('label > span', text: "about us").click
          click_button "Copy"
        end

        error_text = "Node with id #{@about_us.id} has error \"source or descendant node can't be parent of new node\""
        expect(page).to have_css('.dialog .form-error-box', text: error_text)
      end
    end
  end

  describe "move node to", js: true do
    context "when moving node to another parent" do
      it "moves selected node to new position" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @about_us.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")

        within_dialog do
          find('label > span', text: "en").click
          click_button "Move"
        end

        expect(page).to have_css('.notifications .notification .message', text: "Move succeeded")
        expect(page).to have_css('li > .node-cell a', text: "about us", count: 0)
        find('li[data-id="' + @en_root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "about us", count: 1)
      end
    end

    context "when moving node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @about_us.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")

        within_dialog do
          find('label > span', text: "about us").click
          click_button "Move"
        end

        error_text = "Node with id #{@about_us.id} has error \"can't be parent to itself\" on attribute \"parent_id\""
        expect(page).to have_css('.dialog .form-error-box', text: error_text)
      end
    end

  end

  describe "node order", with_tree: false do
    def create_child parent, child_text, position=nil
      visit admin_nodes_path

      open_toolbox_dialog 'Add child', parent, ".view-index .collection li"
      within_dialog do
        click_link("Text page")
      end

      create_resource do
        fill_in 'Name', with: child_text
        fill_in "Slug", with: child_text
        fill_in_richtext 'Text', with: child_text
        if position
          select position, from: 'Item position'
        end
      end

    end

    it "creates nodes in correct order" do
      create_child @lv_root, 'a'
      create_child @lv_root, 'b', 'After a'
      create_child @lv_root, 'c', 'After b'
      create_child @lv_root, 'd', 'After b'
      create_child @lv_root, 'e', 'First'

      visit admin_nodes_path
      find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@lv_root.id}'] ul") do
        expect( page ).to have_content 'e a b d c'
      end
    end

    it "by default adds new nodes as last" do
      create_child @lv_root, 'a'
      create_child @lv_root, 'b'
      create_child @lv_root, 'c'

      visit admin_nodes_path
      find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@lv_root.id}'] ul") do
        expect( page ).to have_content 'a b c'
      end
    end
  end

  describe "creating node for placeholder model", with_tree: false, with_root: false, js: false do
    it "create record in association table" do
      allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
      visit new_admin_node_path(content_type: 'Bundle')
      fill_in("resource_name", with: "placeholder model node")
      expect do
        click_button 'Save'
      end.to change { [Node.count, Bundle.count] }.from([0, 0]).to([1, 1])
    end
  end


  feature "using default releaf content controller", with_releaf_node_controller: true do

    # for this case do not re-test all node features from above
    # just click around a bit to ensure that the controllers, builders and assets work
    # and make sure the public page of the created node works

    scenario "basic node operations" do
      visit "/admin"

      expect(page).to have_no_content 'Admin/nodes'
      within "aside nav" do
        click_link "Releaf/content/nodes"
      end
      expect(current_path).to eq releaf_content_nodes_path

      find('li[data-id="' + @lv_root.id.to_s + '"] > .toolbox-cell button').click
      click_link "Add child"
      within '.ajaxbox-inner .dialog.content-type' do
        click_link "Contacts controller"
      end
      create_resource do
        fill_in "resource_name", with: "Contacts"
      end

      expect(page).to have_breadcrumbs("Releaf/content/nodes", "lv", "Contacts")

      visit lv_contacts_page_path
      expect(page).to have_content "Node class: Node"
      expect(page).to have_content "Releaf github repository"
    end

  end

  feature "using multiple independent node trees", with_multiple_node_classes: true,  with_other_tree: true do

    # here also do not re-test all node features
    # but ensure that controllers, builders and assets work in both admin node controllers
    # and that the per-site configuration and hostname restrictions defined in the node config work on public routes

    scenario "multiple site node operations" do

      visit "/admin"

      # make sure that the admin/nodes controller is not available in menu
      expect(page).to have_no_content 'Admin/nodes'

      # test node creation in releaf/content/nodes controller
      within "aside nav" do
        click_link "Releaf/content/nodes"
      end
      expect(current_path).to eq releaf_content_nodes_path

      find('li[data-id="' + @lv_root.id.to_s + '"] > .toolbox-cell button').click
      click_link "Add child"
      within '.ajaxbox-inner .dialog.content-type' do
        click_link "Contacts controller"
      end
      create_resource do
        fill_in "resource_name", with: "Main contacts"
        fill_in "resource_slug", with: "contacts"
      end
      expect(page).to have_breadcrumbs("Releaf/content/nodes", "lv", "Main contacts")


      # test node creation in the other site nodes controller
      within "aside nav" do
        click_link "Admin/other site/other nodes"
      end
      expect(current_path).to eq admin_other_site_other_nodes_path
      find('li[data-id="' + @other_lv_root.id.to_s + '"] > .toolbox-cell button').click
      click_link "Add child"
      within '.ajaxbox-inner .dialog.content-type' do
        click_link "Contacts controller"
      end
      create_resource do
        fill_in "resource_name", with: "Other contacts"
        fill_in "resource_slug", with: "contacts"
      end
      expect(page).to have_breadcrumbs("Admin/other site/other nodes", "lv", "Other contacts")


      # test public websites for correct url helpers, node types, site settings and host name constraints

      allow(Capybara).to receive(:app_host).and_return "http://releaf.127.0.0.1.xip.io"

      visit main_site_lv_home_page_path
      expect(page).to have_content "Site: main_site"
      expect(page).to have_content "Node class: Node"
      expect(page).to have_content "Node name: lv"

      visit "/lv/about-us"
      expect(URI.parse(current_url).host).to eq "releaf.127.0.0.1.xip.io"
      expect(page).to have_content "Site: main_site"
      expect(page).to have_content "Node class: Node"
      expect(page).to have_content "Node name: about us"

      visit main_site_lv_contacts_page_path
      expect(page).to have_content "Site: main_site"
      expect(page).to have_content "Node class: Node"
      expect(page).to have_content "Node name: Main contacts"

      # make sure the nodes from other site are not reachable via this hostname
      visit "/lv/other-history"
      expect( page ).to have_content "The page you were looking for doesn't exist."


      allow(Capybara).to receive(:app_host).and_return "http://other.releaf.127.0.0.1.xip.io"
      visit other_site_lv_home_page_path
      expect(page).to have_content "Site: other_site"
      expect(page).to have_content "Node class: OtherSite::OtherNode"
      expect(page).to have_content "Node name: Other lv"

      visit "/lv/about-us"
      expect(URI.parse(current_url).host).to eq "other.releaf.127.0.0.1.xip.io"
      expect(page).to have_content "Site: other_site"
      expect(page).to have_content "Node class: OtherSite::OtherNode"
      expect(page).to have_content "Node name: Other about us"

      visit "/lv/other-history"
      expect(page).to have_content "Site: other_site"
      expect(page).to have_content "Node class: OtherSite::OtherNode"
      expect(page).to have_content "Node name: Other history"


      # other site contacts node should not have a route
      # because the route is constrained to main site in dummy application's routes.rb
      visit "/lv/contacts"
      expect( page ).to have_content "The page you were looking for doesn't exist."

    end

  end


end
