require 'spec_helper'
describe "Side menu visual appearance", js: true  do
  before do
    @admin = auth_as_admin
    visit releaf_admin_profile_path
  end

  def wait_for_ajax_update key
    expect{ @admin.settings.try(:[], key) == true }.to become_true
  end

  describe "collapsing functionality" do
    context "when logged first time" do
      it "has side menu opened" do
        expect(page).to_not have_css('body.side-compact')
      end
    end

    context "when click to collapse button" do
      it "collapses side menu" do
        find('.side .compacter button').click

        expect(page).to have_css('body.side-compact')
      end

      it "has permanent collapsing status" do
        find('.side .compacter button').click
        wait_for_ajax_update('releaf.side.compact')
        visit releaf_admin_profile_path

        expect(page).to have_css('body.side-compact')
      end
    end
  end

  describe "menu groups collapsing" do
    context "when logged first time" do
      it "menu item groups is not collapsed" do
        expect(page).to have_css('.side li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when collapsing submenu group with active item" do
      it "collapses menu group" do
        find('.side li[data-name="permissions"] > .trigger').click
        expect(page).to have_css('.side li[data-name="permissions"].collapsed')
      end

      it "does not keep menu group collapsing permanent" do
        find('.side li[data-name="permissions"] > .trigger').click
        wait_for_ajax_update('releaf.menu.collapsed.permissions')

        visit releaf_admins_path
        expect(page).to have_css('.side li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when collapsing submenu group without active item" do
      it "collapses menu group" do
        find('.side li[data-name="inventory"] > .trigger').click

        expect(page).to have_css('.side li[data-name="inventory"].collapsed')
      end

      it "keeps menu group collapsing permanent" do
        find('.side li[data-name="inventory"] > .trigger').click
        wait_for_ajax_update('releaf.menu.collapsed.inventory')
        visit releaf_admin_profile_path

        expect(page).to have_css('.side li[data-name="inventory"].collapsed')
      end
    end
  end
end
