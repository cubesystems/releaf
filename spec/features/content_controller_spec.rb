require 'spec_helper'
describe Releaf::ContentController do
  before do
    @admin = auth_as_admin
    # build little tree
    @root = FactoryGirl.create(:node, name: "RootNode")
    FactoryGirl.create(:node, parent_id: @root.id)
    @sub_root = FactoryGirl.create(:node, parent_id: @root.id)
    FactoryGirl.create(:node, parent_id: @sub_root.id)

    @node = FactoryGirl.create(:node, name: "Main")

    visit releaf_nodes_path
  end

  describe "new node" do
    context "when creating node under root", js: true do
      it "creates new node in content tree" do
        find(".tools .button.primary", text: "Create new item").click
        find('.dialog.add-child-dialog .content_types ul li a', text: "ContactsController").click
        
        fill_in("resource_name", :with => "Main contacts")
        find('.view-edit .new_resource .tools button.primary').click
        
        visit releaf_nodes_path

        expect(page).to have_css('li > .node-cell a', text: "Main contacts", count: 1, visible: true)
      end
    end

    context "when creating node under another node", js: true do
      it "creates new node" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        find('.toolbox-items li a.ajaxbox', text: "Add child").click
        find('.dialog.add-child-dialog .content_types ul li a', text: "ContactsController").click

        fill_in("resource_name", :with => "Contacts")
        find('.view-edit .new_resource .tools button.primary').click

        visit releaf_nodes_path
        find('li[data-id="' + @node.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "Contacts", count: 1, visible: true)
      end
    end
  end

  describe "tree collapsing" do
    context "when not opened before" do
      it "do not show node children", js: true do
        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end

    context "when click to uncollapse node" do
      it "show node children", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keep opened node children visibility permanent", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect { @admin.settings.last.try(:value) == true }.to become_true
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keep closed node children visibility permanent", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect{ @admin.settings.last.try(:value) == false }.to become_true
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_releaf_node_path @node
    end

    context "when going to node from toolbox list", js: true do
      it "navigates to targeted node's edit view" do
        find('.toolbox button').click
        find('.toolbox-items li a.ajaxbox', text: "Go to").click
        find('.dialog.goto-node-dialog .action-tree ul li .node-cell a', text: "RootNode").click

        expect(page).to have_css('.view-edit .edit_resource h2.header', text: 'RootNode', visible: true)
      end
    end
  end

  describe "copy node to" do
    context "when copying node", js: true do
      it "shows copied node in tree" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        find('.toolbox-items li a.ajaxbox', text: "Copy").click
        find('.dialog.copy-node-dialog .action-tree ul li .node-cell button', text: "RootNode").click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li > .node-cell a', text: "Main", count: 2, visible: true)
      end
    end

    context "when copying node under itself", js: true do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        find('.toolbox-items li a.ajaxbox', text: "Copy").click
        find('.dialog.copy-node-dialog .action-tree ul li .node-cell button', text: "Main").click

        expect(page).to have_css('.notifications .notification .message', text: "Copy not possible", visible: true)
      end
    end
  end

  describe "move node to" do
    context "when moving node to another parent", js: true do
      it "moves selected node to new position" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        find('.toolbox-items li a.ajaxbox', text: "Move").click
        find('.dialog.move-node-dialog .action-tree ul li .node-cell button', text: "RootNode").click
        expect(page).not_to have_css('li > .node-cell a', text: "Main", visible: true)

        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click

        expect(page).to have_css('li > .node-cell a', text: "Main", count: 1, visible: true)
      end
    end

    context "when moving node under itself", js: true do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        find('.toolbox-items li a.ajaxbox', text: "Move").click
        find('.dialog.move-node-dialog .action-tree ul li .node-cell button', text: "Main").click

        expect(page).to have_css('.notifications .notification .message', text: "Move not possible", visible: true)
      end
    end

  end
end
