require 'spec_helper'
feature "Richtext editing", js: true do
  background do
    auth_as_user
  end

  scenario "Image toolbar available when controller support attachments" do
    visit new_releaf_content_node_path(content_type: 'TextPage')
    fill_in_richtext 'resource_content_attributes_text_html', "some text"
    expect(page).to have_css("a.cke_button__image")
  end

  scenario "Image toolbar unavailable when controller doesn't support attachments" do
    visit new_admin_book_path
    fill_in_richtext 'resource_summary_html', "some text"
    expect(page).to_not have_css("a.cke_button__image")
  end
end
