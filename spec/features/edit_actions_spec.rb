require 'spec_helper'
feature "Base controller edit", js: true do
  background do
    auth_as_admin
    @author = FactoryGirl.create(:author)
    @good_book = FactoryGirl.create(:book, title: "good book", author: @author, price: 12.34, description_lv: "in lv", description_en: "in en")
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

    expect(page).to have_css('.delete-restricted-dialog.dialog .content .restricted-relations .relations li', :count => 2)
  end

  scenario "when clicking on delete restriction relation, it opens edit for related object" do
    visit edit_admin_author_path @author
    find('.toolbox button.trigger').click
    find('.toolbox-items li a.ajaxbox', text: "Delete").click

    find('.delete-restricted-dialog.dialog .content .restricted-relations .relations li', :text => "good book").click

    expect(page).to have_css('.view-edit h2.header', text: "good book")
  end

  scenario "remember last active locale for localized fields" do
    visit admin_book_path(id: @good_book.id)
    within(".localization-switch") do
      click_button("en")
    end

    within(".localization-menu-items") do
      click_button("lv")
    end

    visit admin_book_path(id: @good_book.id)
    expect(page).to have_css('#resource_description_lv[value="in lv"]')
  end

  scenario "editing book uses Book#price instead of Book[:price] (issue #95)" do
    visit admin_book_path(id: @good_book.id)
    expect(page).to have_css('#resource_price[value="12.34"]')
  end

  scenario "editing nested object with :allow_destroy => false" do
    visit admin_book_path(id: @good_book.id)
    expect(page).to_not have_css('.remove-nested-item')

    find('.add-nested-item').click
    expect(page).to have_css('.remove-nested-item')

    fill_in 'resource_chapters_attributes_0_title', :with => 'Chapter 1'
    fill_in 'resource_chapters_attributes_0_text', :with => 'todo'

    find('button.primary[type="submit"]').click
    expect(page).to_not have_css('.remove-nested-item')
    expect(page).to have_css('#resource_chapters_attributes_0_title[value="Chapter 1"]')
  end
end
