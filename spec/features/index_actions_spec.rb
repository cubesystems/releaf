require 'spec_helper'
feature "Base controller index", js: true do
  background do
    auth_as_admin
    @good_book = FactoryGirl.create(:book, title: "good book")
    FactoryGirl.create(:book, title: "bad book")
  end

  scenario "shows resource count" do
    visit admin_books_path
    expect(page).to have_content('2 Resources found')
  end

  scenario "search resources dynamically" do
    visit admin_books_path
      within("form.search") do
        fill_in 'search', :with => "good"
      end
    expect(page).to have_content('1 Resources found')
  end

  scenario "keeps search parameters when navigating to edit and back" do
    visit admin_books_path(search: "good")
    click_link("good book")
    click_link("Back to list")

    expect(page).to have_css('.main > .table > tbody .row', :count => 1)
  end

  scenario "keeps search parameters after delete" do
    visit admin_books_path(search: "good")
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click
    find('.dialog.delete_dialog .footer button.danger', text: "Yes").click
    expect(page).to have_css('.main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end

  scenario "when deleting item in edit" do
    visit admin_books_path(search: "good")
    click_link("good book")
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click
    find('.dialog.delete_dialog .footer button.danger', text: "Yes").click

    expect(page).to have_css('.view-index .main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end
end
