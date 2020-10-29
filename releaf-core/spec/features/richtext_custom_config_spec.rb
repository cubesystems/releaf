require 'rails_helper'
feature "Richtext custom config", js: true do
  background do
    # preload ActsAsNode classes
    Rails.application.eager_load!
    auth_as_user
  end

  scenario "Add embed to richtext" do
    visit new_admin_book_path
    wait_for_all_richtexts

    within "section[data-name=\"chapters\"]" do
      click_button "Add item"
      expect(page).to have_css(".cke_toolbar a.cke_button__bold")
      expect(page).to have_css(".cke_toolbar a.cke_button__italic")
      expect(page).to_not have_css(".cke_toolbar a.cke_button__image")
      expect(page).to_not have_css(".cke_toolbar a.cke_button__format")
    end

    within ".field[data-name=\"summary_html\"]" do
      expect(page).to have_css(".cke_toolbar a.cke_button__bold")
      expect(page).to have_css(".cke_toolbar a.cke_button__italic")
      expect(page).to have_css(".cke_toolbar a.cke_button__image")
      expect(page).to_not have_css(".cke_toolbar a.cke_button__format")
    end
  end
end
