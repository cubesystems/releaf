require 'spec_helper'
describe "Nodes", js: true, with_tree: true, with_root: true do
  before do
    # preload ActsAsNode classes
    Rails.application.eager_load!

    @user = auth_as_user
  end

  before with_root: true do
    @root = FactoryGirl.create(:node, name: "RootNode")
  end

  before with_tree: true do
    FactoryGirl.create(:node, parent_id: @root.id)
    @sub_root = FactoryGirl.create(:node, parent_id: @root.id)
    FactoryGirl.create(:node, parent_id: @sub_root.id)

    @node = FactoryGirl.create(:node, name: "Main")

    visit releaf_content_nodes_path
  end

  describe "new node" do
    context "when creating node under root" do
      it "creates new node in content tree" do
        click_link("Create new resource")
        click_link("Contacts controller")
        fill_in("resource_name", with: "RootNode2")
        save_and_check_response('Create succeeded')

        expect(page).to have_content('Releaf/content/nodes RootNode2')
      end
    end

    context "when creating node under another node" do
      it "creates new node" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        click_link("Add child")
        click_link("Contacts controller")
        fill_in("resource_name", with: "Contacts")
        save_and_check_response('Create succeeded')

        expect(page).to have_content('Releaf/content/nodes RootNode Contacts')
      end
    end
  end

  describe "tree collapsing" do

    context "when not opened before" do
      it "does not show node's children" do
        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end

    context "when clicked to uncollapse node" do
      it "shows node children" do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps opened node children visibility permanent" do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        wait_for_settings_update("content.tree.expanded.#{@root.id}")
        visit releaf_content_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps closed node children visibility permanent" do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        wait_for_settings_update("content.tree.expanded.#{@root.id}", false)
        visit releaf_content_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_releaf_content_node_path @node
    end

    context "when going to node from toolbox list" do
      it "navigates to targeted node's edit view" do
        open_toolbox('Go to')
        click_link("RootNode")

        expect(page).to have_css('.view-edit .edit-resource h2.header', text: 'RootNode')
      end
    end
  end

  describe "copy node to" do
    context "when copying node" do
      it "shows copied node in tree" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")

        find('.copy-or-move-node-dialog form[data-validation-initialized="true"]')
        within '.copy-or-move-node-dialog' do
          find('label > span', text: "RootNode").click
          click_button "Copy"
        end

        expect(page).to have_css('.notifications .notification .message', text: "Copy succeeded")

        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "Main", count: 2)
      end
    end

    context "when copying node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")

        find('.copy-or-move-node-dialog form[data-validation-initialized="true"]')
        within '.copy-or-move-node-dialog' do
          find('label > span', text: "Main").click
          click_button "Copy"
        end

        expect(page).to have_css('.copy-or-move-node-dialog .form-error-box', text: "Source or descendant node can't be parent of new node")
      end
    end
  end

  describe "move node to", js: true do
    context "when moving node to another parent" do
      it "moves selected node to new position" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")

        find('.copy-or-move-node-dialog form[data-validation-initialized="true"]')
        within '.copy-or-move-node-dialog' do
          find('label > span', text: "RootNode").click
          click_button "Move"
        end

        expect(page).to have_css('.notifications .notification .message', text: "Move succeeded")
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "Main", count: 1)
      end
    end

    context "when moving node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")

        find('.copy-or-move-node-dialog form[data-validation-initialized="true"]')
        within '.copy-or-move-node-dialog' do
          find('label > span', text: "Main").click
          click_button "Move"
        end

        expect(page).to have_css('.copy-or-move-node-dialog .form-error-box', text: "Can't be parent to itself")
      end
    end

  end

  describe "node order", with_tree: false do
    def create_child parent, child_text, position=nil
      visit releaf_content_nodes_path
      open_toolbox 'Add child', parent, true
      within ".add-child-dialog" do
        click_link("Text")
      end

      fill_in 'Name', with: child_text
      fill_in "Slug", with: child_text
      fill_in_richtext 'resource_content_attributes_text_html', child_text
      if position
        select position, from: 'Item position'
      end
      save_and_check_response "Create succeeded"
    end

    it "creates nodes is correct order" do
      create_child @root, 'a'
      create_child @root, 'b', 'After a'
      create_child @root, 'c', 'After b'
      create_child @root, 'd', 'After b'
      create_child @root, 'e', 'First'

      visit releaf_content_nodes_path
      find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@root.id}'] ul.block") do
        expect( page ).to have_content 'e a b d c'
      end
    end

    it "by default adds new nodes as last" do
      create_child @root, 'a'
      create_child @root, 'b'
      create_child @root, 'c'

      visit releaf_content_nodes_path
      find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

      within(".collection li[data-level='1'][data-id='#{@root.id}'] ul.block") do
        expect( page ).to have_content 'a b c'
      end
    end
  end

  describe "creating node for placeholder model", with_tree: false, with_root: false, js: false do
    it "create record in association table" do
      visit new_releaf_content_node_path(content_type: 'Bundle')
      fill_in("resource_name", with: "placeholder model node")
      expect do
        click_button 'Save'
      end.to change { [Node.count, Bundle.count] }.from([0, 0]).to([1, 1])
    end
  end
end
