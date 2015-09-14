require 'spec_helper'
describe "Nodes", js: true, with_tree: true, with_root: true do
  before do
    Rails.cache.clear
    # preload ActsAsNode classes
    Rails.application.eager_load!
    @user = auth_as_user
  end

  before with_root: true do
    @lv_root = create(:home_page_node, name: "lv", locale: "lv")
  end

  before with_tree: true do
    @how_to = create(:text_page_node, parent_id: @lv_root.id)
    @about_us = create(:text_page_node, parent_id: @lv_root.id, name: "about us")
    @history_node = create(:text_page_node, parent_id: @about_us.id, name: "history")

    @en_root = create(:home_page_node, name: "en", locale: "en")

    visit releaf_content_nodes_path
  end

  describe "new node" do
    context "when creating node under root" do
      it "creates new node in content tree" do
        @en_root.destroy
        click_link "Create new resource"
        click_link "Home page"
        create_resource do
          fill_in "resource_name", with: "en"
          select "en", from: "Locale"
        end

        expect(page).to have_breadcrumbs("Releaf/content/nodes", "en")
      end
    end

    context "when creating node under another node" do
      it "creates new node" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .toolbox-cell button').click
        click_link "Add child"
        click_link "Contacts controller"
        create_resource do
          fill_in "resource_name", with: "Contacts"
        end

        expect(page).to have_breadcrumbs("Releaf/content/nodes", "lv", "Contacts")
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
        visit releaf_content_nodes_path

        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps closed node children visibility permanent" do
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click
        wait_for_settings_update("content.tree.expanded.#{@lv_root.id}", false)
        visit releaf_content_nodes_path

        expect(page).to have_css('li[data-id="' + @lv_root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_releaf_content_node_path @en_root
    end

    context "when going to node from toolbox list" do
      it "navigates to targeted node's edit view" do
        expect(page).to_not have_header(text: 'lv')
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

        error_text = 'Node with id 3 has error "source or descendant node can\'t be parent of new node"'
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

        error_text = 'Node with id 3 has error "can\'t be parent to itself" on attribute "parent_id"'
        expect(page).to have_css('.dialog .form-error-box', text: error_text)
      end
    end

  end

  describe "node order", with_tree: false do
    def create_child parent, child_text, position=nil
      visit releaf_content_nodes_path
      open_toolbox_dialog 'Add child', parent, ".view-index .collection li"
      within_dialog do
        click_link("Text")
      end

      fill_in 'Name', with: child_text
      fill_in "Slug", with: child_text
      fill_in_richtext 'Text', with: child_text
      if position
        select position, from: 'Item position'
      end
      save_and_check_response "Create succeeded"
    end

    it "creates nodes is correct order" do
      create_child @lv_root, 'a'
      create_child @lv_root, 'b', 'After a'
      create_child @lv_root, 'c', 'After b'
      create_child @lv_root, 'd', 'After b'
      create_child @lv_root, 'e', 'First'

      visit releaf_content_nodes_path
      find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@lv_root.id}'] ul.block") do
        expect( page ).to have_content 'e a b d c'
      end
    end

    it "by default adds new nodes as last" do
      create_child @lv_root, 'a'
      create_child @lv_root, 'b'
      create_child @lv_root, 'c'

      visit releaf_content_nodes_path
      find('li[data-id="' + @lv_root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@lv_root.id}'] ul.block") do
        expect( page ).to have_content 'a b c'
      end
    end
  end

  describe "creating node for placeholder model", with_tree: false, with_root: false, js: false do
    it "create record in association table" do
      allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
      visit new_releaf_content_node_path(content_type: 'Bundle')
      fill_in("resource_name", with: "placeholder model node")
      expect do
        click_button 'Save'
      end.to change { [Node.count, Bundle.count] }.from([0, 0]).to([1, 1])
    end
  end
end
