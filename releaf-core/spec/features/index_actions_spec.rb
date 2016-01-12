require 'rails_helper'
feature "Base controller index", js: true do
  background do
    auth_as_user
    author = FactoryGirl.create(:author)
    good_book = FactoryGirl.create(:book, title: "good book", author: author, published_at: Date.parse("2015-12-12"))
    FactoryGirl.create(:chapter, title: 'Scary night', text: 'Once upon a time...', book: good_book)
    FactoryGirl.create(:book, title: "bad book", author: author)
  end

  scenario "shows resource count" do
    visit admin_books_path
    expect(page).to have_number_of_resources(2)
  end

  scenario "search resources dynamically" do
    visit admin_books_path
    search "good"
    expect(page).to have_number_of_resources(1)

    check "Only active"
    expect(page).to have_number_of_resources(0)

    uncheck "Only active"
    expect(page).to have_number_of_resources(1)

    fill_in "Published between", with: "2015-11-11"
    click_button "Filter"

    expect(page).to have_number_of_resources(1)
  end

  scenario "search by 2nd level nested fields" do
    visit admin_authors_path
    search "upon"
    expect(page).to have_number_of_resources(1)
  end

  scenario "search nonexisting stuff" do
    visit admin_authors_path
    search "bunnyrabit"
    expect(page).to have_number_of_resources(0)
  end

  scenario "no row urls when :edit feature is not available" do
    visit admin_books_path
    expect(page).to have_link("good book")

    allow_any_instance_of(Admin::BooksController).to receive(:feature_available?).with(:edit).and_return(false)
    visit admin_books_path
    expect(page).to_not have_link("good book")
  end

  scenario "keeps search parameters when navigating to edit and back" do
    visit admin_books_path(search: "good")
    click_link("good book")
    wait_for_all_richtexts
    click_link("Back to list")
    expect(page).to have_number_of_resources(1)
  end

  scenario "keeps search parameters after delete" do
    visit admin_books_path(search: "good")
    open_toolbox_dialog('Delete', Book.first)
    click_button("Yes")
    expect(page).to have_number_of_resources(0)
  end

  scenario "when deleting item in edit" do
    visit admin_books_path(search: "good")
    click_link("good book")
    open_toolbox_dialog('Delete')
    click_button("Yes")
    expect(page).to have_number_of_resources(0)
  end

  scenario "when deleting item with restrict relation" do
    visit admin_authors_path
    open_toolbox_dialog('Delete', Author.first)

    within_dialog do
      expect(page).to have_css('.restricted-relations .relations li', count: 2)
    end
  end
end
