require 'spec_helper'
describe Releaf::ContentController do
  before do
    auth_as_admin
    # build little tree
    @root = FactoryGirl.create(:node)
    FactoryGirl.create(:node, parent_id: @root.id)
    @sub_root = FactoryGirl.create(:node, parent_id: @root.id)
    FactoryGirl.create(:node, parent_id: @sub_root.id)

    visit releaf_nodes_path
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
        visit releaf_nodes_path
        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"]:not(.collapsed)')
      end

      it "keep closed node children visibility permanent", js: true do
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        find('li[data-id="' + @root.id.to_s + '"] > .collapser-cell button').click
        visit releaf_nodes_path
        expect(page).to have_css('li[data-id="' + @root.id.to_s + '"].collapsed')
      end
    end
  end
end
