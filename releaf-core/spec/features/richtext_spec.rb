require 'rails_helper'
feature "Richtext editing", js: true do
  background do
    auth_as_user
  end

  scenario "Image toolbar available when controller support attachments" do
    visit new_admin_node_path(content_type: 'TextPage')
    wait_for_all_richtexts
    fill_in_richtext 'Text', with: "some text"
    expect(page).to have_css("a.cke_button__image")
  end

  scenario "Image toolbar unavailable when controller doesn't support attachments" do
    allow_any_instance_of(Admin::BooksController).to receive(:releaf_richtext_attachment_upload_url).and_return("")
    visit new_admin_book_path
    wait_for_all_richtexts
    fill_in_richtext "Summary", with: "some text"
    expect(page).to_not have_css("a.cke_button__image")
  end

  scenario "Test helper fills in correct value" do
    visit new_admin_node_path(content_type: 'TextPage')
    html = %Q[ <p class="xxx" id='yyy'> &quot;HTML&quot; 'content' </p> ]
    wait_for_all_richtexts
    fill_in_richtext 'Text', with: html
    content = evaluate_script('CKEDITOR.instances["resource_content_attributes_text_html"].getData();')
    expect(content).to match_html html
  end

end
