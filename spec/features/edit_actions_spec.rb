require 'spec_helper'
feature "Base controller edit", js: true do
  background do
    auth_as_admin
    @author = FactoryGirl.create(:author)
    @good_book = FactoryGirl.create(:book, title: "good book", author: @author)
    FactoryGirl.create(:book, title: "bad book", author: @author)
  end

  scenario "keeps search params after deleting record from edit view" do
    visit admin_books_path(search: "good")
    click_link("good book")
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click
    find('.dialog.delete_dialog .footer button.danger', text: "Yes").click

    expect(page).to have_css('.main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end

  scenario "when deleting item with restrict relation" do
    visit edit_admin_author_path @author
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click

    expect(page).to have_css('.delete_restricted_dialog.dialog .content .restricted_relations li', :count => 2)
  end
end
