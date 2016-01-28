require 'rails_helper'
feature "Richtext editing", js: true do
  background do
    auth_as_user
  end

  scenario "Image toolbar available when controller support attachments" do
    visit new_admin_node_path(content_type: 'TextPage')
    fill_in_richtext 'Text', with: "some text"
    expect(page).to have_css("a.cke_button__image")
  end

  scenario "Image toolbar unavailable when controller doesn't support attachments" do
    allow_any_instance_of(Admin::BooksController).to receive(:releaf_richtext_attachment_upload_url).and_return("")
    visit new_admin_book_path
    fill_in_richtext "Summary", with: "some text"
    expect(page).to_not have_css("a.cke_button__image")
  end
end
