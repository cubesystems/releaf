require 'rails_helper'
feature "Base controller edit", js: true do
  background do
    auth_as_user
    @author = FactoryGirl.create(:author)
    @good_book = FactoryGirl.create(:book, title: "good book", author: @author, price: 12.34, description_lv: "in lv", description_en: "in en")
    FactoryGirl.create(:book, title: "bad book", author: @author)
  end

  scenario "creation of new resources" do

    # normal save button redirects to edit view of the newly created resource
    visit admin_books_path
    click_link "Create new resource"
    wait_for_all_richtexts
    fill_in "Title", with: "Lorem ipsum"
    click_button 'Save'
    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Create succeeded")
    wait_for_all_richtexts
    expect(page).to have_css('header h1', text: 'Lorem ipsum')

    # "save and create another" button redirects to new resource view
    visit new_admin_book_path
    wait_for_all_richtexts
    fill_in "Title", with: "Other ipsum"
    click_button "Save and create another"
    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Create succeeded")
    wait_for_all_richtexts
    expect(current_path).to eq new_admin_book_path
    expect(page).to have_css('header h1', text: 'Create new resource')

    # ENTER key in a field defaults to "save and create another"
    visit new_admin_book_path
    wait_for_all_richtexts
    fill_in "Title", with: "Another ipsum"
    find('#resource_title').native.send_key(:Enter)
    expect(page).to have_css('body > .notifications .notification[data-id="resource_status"][data-type="success"]', text: "Create succeeded")
    expect(page).to have_css('header h1', text: 'Create new resource')

  end

  scenario "keeps search params after deleting record from edit view" do
    visit admin_books_path(search: "good")
    click_link("good book")
    open_toolbox_dialog("Delete")
    click_button("Yes")
    expect(page).to have_number_of_resources(0)
  end

  scenario "when deleting item with restrict relation" do
    visit edit_admin_author_path @author
    open_toolbox_dialog("Delete")

    within_dialog do
      expect(page).to have_css('.restricted-relations .relations li', count: 2)
    end
  end

  scenario "drag and drop nested items with ckeditors" do
      skip "implement drag and drop test"
  end

  scenario "when clicking on delete restriction relation, it opens edit for related object" do
    visit edit_admin_author_path @author
    open_toolbox_dialog("Delete")

    within_dialog do
      find('.restricted-relations .relations li a', text: "good book").click
    end
    expect(page).to have_header(text: "good book")
  end

  scenario "remember last active locale for localized fields" do
    visit admin_book_path(id: @good_book.id)
    within(".localization-switch") do
      click_button "en"
    end

    within(".localization-menu-items") do
      click_button "Lv"
    end
    wait_for_all_richtexts

    visit admin_book_path(id: @good_book.id)
    expect(page).to have_css('#resource_description_lv[value="in lv"]')
  end

  scenario "editing book uses Book#price instead of Book[:price] (issue #95)" do
    visit admin_book_path(id: @good_book.id)
    expect(page).to have_css('#resource_price[value="12.34"]')
  end

  scenario "do not show 'Back to list' url when no index url passed" do
    visit admin_books_path(search: "good")
    click_link("good book")
    expect(page).to have_link("Back to list")
    wait_for_all_richtexts

    visit admin_book_path(Book.first)
    expect(page).to_not have_link("Back to list")
  end

  scenario "editing nested object with allow_destroy: false" do
    visit admin_book_path(id: @good_book.id)
    expect(page).to_not have_css('.remove-nested-item')

    update_resource do
      find('.nested[data-name="chapters"] .add-nested-item').click
      expect(page).to have_css('.remove-nested-item')
      fill_in 'resource_chapters_attributes_0_title', with: 'Chapter 1'
      fill_in 'resource_chapters_attributes_0_text', with: 'todo'
      fill_in_richtext 'Sample', with: "xx"
    end

    expect(page).to_not have_css('.remove-nested-item')
    expect(page).to have_css('#resource_chapters_attributes_0_title[value="Chapter 1"]')
  end

  scenario "adding nested objects" do
    visit new_admin_book_path

    create_resource do
      fill_in "Title", with: "Master and Margarita"
      within "[data-name='chapters']" do

        # verify that there are no visible inputs
        expect( page ).to have_no_selector('input', visible: true)
        expect( page ).to have_no_selector('textarea', visible: true)

        click_button "Add item"

        fill_in "Title", with: "Chapter 1"
        fill_in "Text", with: "some text"
        fill_in_richtext 'Sample', with: "xx"
      end
    end

    new_book = Book.where(title: "Master and Margarita").first
    expect( new_book.chapters.count ).to eq 1
    expect( new_book.chapters.first.title ).to eq "Chapter 1"
  end

  scenario "using datetime picker widget" do
    visit new_admin_book_path

    create_resource do
      fill_in "Title", with: "Mustard and Margarine"
      expect(page).to have_css('.field.type-datetime[data-name="published_at"] input.hasDatepicker')
      expect(find_field('Published at').value).to eq ''
      expect(page.document).to have_no_css '#ui-datepicker-div'
      find('label', text: 'Published at').click
      within page.document.find('#ui-datepicker-div') do
        find('.ui-datepicker-month option', text: 'Apr').select_option
        find('.ui-datepicker-year option', text: '2018').select_option
        date_cell_selector = '.ui-datepicker-calendar tbody td[data-month="3"][data-year="2018"]'
        find(date_cell_selector, text: '20').click
        expect(page).to have_css("#{date_cell_selector}.ui-datepicker-current-day", text: '20')

        find('.ui_tpicker_hour select option', text: '23').select_option
        find('.ui_tpicker_minute select option', text: '45').select_option
        expect(page).to have_no_css('.ui_tpicker_second select')
        expect(page).to have_no_css('.ui_tpicker_millisec select')
        expect(page).to have_no_css('.ui_tpicker_timezone select')
        click_on 'Done'
      end
      expect(page.document).to have_no_css '#ui-datepicker-div'
      expect(find_field('Published at').value).to eq '2018-04-20 23:45'
    end

    visit admin_books_path
    expect(page).to have_css 'tr', text: /\AMustard and Margarine No 2018-04-20 23:45\z/
    click_on "Mustard and Margarine"
    expect(find_field('Published at').value).to eq '2018-04-20 23:45'
    find('label', text: 'Published at').click
    within page.document.find('#ui-datepicker-div') do
      expect(find('select.ui-datepicker-month option:checked').text).to eq 'Apr'
      expect(find('select.ui-datepicker-year option:checked').text).to eq '2018'
      expect(page).to have_css('.ui-datepicker-calendar tbody td[data-month="3"][data-year="2018"].ui-datepicker-current-day', text: '20')

      expect(find('.ui_tpicker_hour select option:checked').text).to eq '23'
      expect(find('.ui_tpicker_minute select option:checked').text).to eq '45'
    end

  end

end
