require 'spec_helper'
feature "Dragonfly integration", js: true do
  background do
    auth_as_user
  end

  scenario "Upload, view and remove image" do
    visit new_admin_book_path
    create_resource do
      fill_in "Title", with: "xx"
      attach_file "Cover image", File.expand_path('../fixtures/cs.png', __dir__)
    end

    find(".field[data-name='cover_image'] a.ajaxbox" ).click
    expect(page).to have_css(".fancybox-inner img.fancybox-image")
    find(".fancybox-inner button.close" ).click
    expect(page).to have_no_css(".fancybox-inner img.fancybox-image")

    update_resource do
      check "Remove"
    end
    expect(page).to have_no_css(".field[data-name='cover_image'] a.ajaxbox")
  end
end
