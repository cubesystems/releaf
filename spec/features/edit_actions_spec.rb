require 'spec_helper'
feature "Base controller index actions", js: true do
  background do
    auth_as_admin
    @good_book = FactoryGirl.create(:book, title: "good book")
    FactoryGirl.create(:book, title: "bad book")
  end

  scenario "keep search params after deleting record from edit view" do
    visit admin_books_path(search: "good")
    click_link("good book")
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click
    find('.dialog.delete_dialog .footer button.danger', text: "Yes").click

    expect(page).to have_css('.main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end
end
