require 'spec_helper'
feature "Base controller index actions" do
  background do
    auth_as_admin
    @good_book = FactoryGirl.create(:book, title: "good book")
    FactoryGirl.create(:book, title: "bad book")
  end

  scenario "keep search parameters when navigating to edit and back" do
    visit admin_books_path(search: "good")
    click_link("good book")
    click_link("Back to list")

    expect(page).to have_css('.main > .table > tbody .row', :count => 1)
  end
end
