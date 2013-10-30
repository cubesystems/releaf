require 'spec_helper'
describe Releaf::ContentController, js: true do
  before do
    # preload ActsAsNode classes
    Rails.application.eager_load!

    @admin = auth_as_admin
    # build little tree
    @root = FactoryGirl.create(:node, name: "RootNode")
    FactoryGirl.create(:node, parent_id: @root.id)
    @sub_root = FactoryGirl.create(:node, parent_id: @root.id)
    FactoryGirl.create(:node, parent_id: @sub_root.id)

    @node = FactoryGirl.create(:node, name: "Main")

    visit releaf_nodes_path
  end

  def wait_for_ajax_update key, value = true
    expect{ @admin.settings.try(:[], key) == value }.to become_true
  end

  describe "new node" do
    context "when creating node under root" do
      it "creates new node in content tree" do
        click_link("Create new item")
        click_link("ContactsController")
        fill_in("resource_name", :with => "RootNode2")
        click_button('Save')

        expect(page).to have_content('Releaf/content RootNode2')
      end
    end

    context "when creating node under another node" do
      it "creates new node" do
        find('li[data-id="' + @root.id.to_s + '"] > .toolbox-cell button').click
        click_link("Add child")
        click_link("ContactsController")

        fill_in("resource_name", :with => "Contacts")
        click_button('Save')

        expect(page).to have_content('Releaf/content RootNode Contacts')
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
        wait_for_ajax_update("content.tree.expanded.#{@root.id}")
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keeps closed node children visibility permanent" do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        wait_for_ajax_update("content.tree.expanded.#{@root.id}", false)
        visit releaf_nodes_path

        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end
  end

  describe "go_to node" do
    before do
      visit edit_releaf_node_path @node
    end

    context "when going to node from toolbox list" do
      it "navigates to targeted node's edit view" do
        find('.toolbox button').click
        click_link("Go to")
        click_link("RootNode")

        expect(page).to have_css('.view-edit .edit_resource h2.header', text: 'RootNode')
      end
    end
  end

  describe "copy node to" do
    context "when copying node" do
      it "shows copied node in tree" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")
        click_button("RootNode")
        expect(page).to have_css('.notifications .notification .message', text: "Copy to node ok")

        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "Main", count: 2)
      end
    end

    context "when copying node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Copy")
        click_button("Main")
        expect(page).to have_css('.notifications .notification .message', text: "Copy to node not ok")
      end
    end
  end

  describe "move node to" do
    context "when moving node to another parent" do
      it "moves selected node to new position" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")
        click_button("RootNode")

        expect(page).to have_css('.notifications .notification .message', text: "Move to node ok")
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        expect(page).to have_css('li > .node-cell a', text: "Main", count: 1)
      end
    end

    context "when moving node under itself" do
      it "displays flash error message" do
        find('li[data-id="' + @node.id.to_s + '"] > .toolbox-cell button').click
        click_link("Move")
        click_button("Main")

        expect(page).to have_css('.notifications .notification .message', text: "Move to node not ok")
      end
    end
  end
end
