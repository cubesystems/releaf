require 'rails_helper'
describe "Side menu visual appearance", js: true  do
  before do
    Rails.cache.clear
    @user = auth_as_user
    visit releaf_permissions_user_profile_path
  end

  describe "collapsing functionality" do
    context "when logged first time" do
      it "has side menu opened" do
        expect(page).to_not have_css('body.side-compact')
      end
    end

    context "when click to collapse button" do
      it "collapses side menu" do
        find('aside .compacter button').click

        expect(page).to have_css('body.side-compact')
      end

      it "has permanent collapsing status" do
        find('aside .compacter button').click
        wait_for_settings_update('releaf.side.compact')
        visit releaf_permissions_user_profile_path

        expect(page).to have_css('body.side-compact')
      end
    end
  end

  describe "menu groups collapsing" do
    context "when logged first time" do
      it "menu item groups is not collapsed" do
        expect(page).to have_css('aside li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when collapsing submenu group with active item" do
      it "collapses menu group" do
        find('aside li[data-name="permissions"] > .trigger').click
        expect(page).to have_css('aside li[data-name="permissions"].collapsed')
      end

      it "does not keep menu group collapsing permanent" do
        find('aside li[data-name="permissions"] > .trigger').click
        wait_for_settings_update('releaf.menu.collapsed.permissions')

        visit releaf_permissions_users_path
        expect(page).to have_css('aside li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when collapsing submenu group without active item" do
      it "collapses menu group" do
        find('aside li[data-name="inventory"] > .trigger').click

        expect(page).to have_css('aside li[data-name="inventory"].collapsed')
      end

      it "keeps menu group collapsing permanent" do
        find('aside li[data-name="inventory"] > .trigger').click
        wait_for_settings_update('releaf.menu.collapsed.inventory')
        visit releaf_permissions_user_profile_path

        expect(page).to have_css('aside li[data-name="inventory"].collapsed')
      end
    end
  end
end
