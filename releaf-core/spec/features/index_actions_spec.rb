require 'spec_helper'
feature "Base controller index", js: true do
  background do
    auth_as_admin
    @author = FactoryGirl.create(:author)
    @good_book = FactoryGirl.create(:book, title: "good book", author: @author)
    @chapter = FactoryGirl.create(:chapter, title: 'Scary night', text: 'Once upon a time...', book: @good_book)
    FactoryGirl.create(:book, title: "bad book", author: @author)
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

  scenario "search by 2nd level nested fields" do
    visit admin_authors_path
    within("form.search") do
      fill_in 'search', :with => "upon"
    end

    expect(page).to have_content('1 Resources found')
  end

  scenario "search nonexisting stuff" do
    visit admin_authors_path
    within("form.search") do
      fill_in 'search', :with => "bunnyrabit"
    end

    expect(page).to have_content('Nothing found')
  end

  scenario "keeps search parameters when navigating to edit and back" do
    visit admin_books_path(search: "good")
    click_link("good book")
    click_link("Back to list")

    expect(page).to have_css('.main > .table > tbody .row', :count => 1)
  end

  scenario "keeps search parameters after delete" do
    visit admin_books_path(search: "good")
    open_toolbox('Delete', Book.first)
    click_button("Yes")
    expect(page).to have_css('.main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end

  scenario "when deleting item in edit" do
    visit admin_books_path(search: "good")
    click_link("good book")
    open_toolbox('Delete')
    click_button("Yes")
    expect(page).to have_css('.view-index .main > .table th .nothing_found', :count => 1, :text => "Nothing found")
  end

  scenario "when deleting item with restrict relation" do
    visit admin_authors_path
    open_toolbox('Delete', Author.first)

    expect(page).to have_css('.delete-restricted-dialog.dialog .content .restricted-relations .relations li', :count => 2)
  end
end
