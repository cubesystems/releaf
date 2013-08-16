require 'spec_helper'
describe "Side menu visual appearance" do
  before do
    @admin = auth_as_admin
    visit releaf_admin_profile_path
  end

  describe "collapsing functionality" do
    context "when logged first time" do
      it "have side menu opened", js: true do
        expect(page).to_not have_css('body.side-compact')
      end
    end

    context "when click to collapse button", js: true do
      it "collapses side menu", js: true do
        find('.side .compacter button').click

        expect(page).to have_css('body.side-compact')
      end

      it "have permanent collapsing status", js: true do
        find('.side .compacter button').click
        page.wait_until{ @admin.settings.last.try(:value) == true }
        visit releaf_admin_profile_path

        expect(page).to have_css('body.side-compact')
      end
    end
  end

  describe "menu item collapsing functionality" do
    context "when logged first time" do
      it "permissions is not collapsed", js: true do
        expect(page).to have_css('.side li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when submenu item is active" do
      it "its parent menu is expanded", js: true do
        find('.side li[data-name="permissions"] > .trigger').click
        expect(page).to have_css('.side li[data-name="permissions"].collapsed')

        page.wait_until{ @admin.settings.last.try(:value) == true }
        visit releaf_admins_path

        expect(page).to have_css('.side li[data-name="permissions"]:not(.collapsed)')
      end
    end

    context "when click to inventory item", js: true do
      it "collapse submenu", js: true do
        find('.side li[data-name="inventory"] > .trigger').click

        expect(page).to have_css('.side li[data-name="inventory"].collapsed')
      end

      it "have permanent collapsed status", js: true do
        find('.side li[data-name="inventory"] > .trigger').click
        page.wait_until{ @admin.settings.last.try(:value) == true }
        visit releaf_admin_profile_path

        expect(page).to have_css('.side li[data-name="inventory"].collapsed')
      end
    end
  end
end
