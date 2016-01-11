require 'rails_helper'
feature "Richtext embed", js: true do
  background do
    # preload ActsAsNode classes
    Rails.application.eager_load!
    auth_as_user
  end

  scenario "Add embed to richtext" do
    visit new_admin_node_path(content_type: 'HomePage')
    fill_in("Name", with: "Embed test")
    select('en', from: 'Locale')

    status_script = 'CKEDITOR.instances["resource_content_attributes_intro_text_html"].status=="ready"'
    expect { page.evaluate_script(status_script) }.to become_true

    find(".cke_toolbox a[title='Embed Media']").click
    expect(page).to have_css(".cke_dialog_title", text: "Embed Media")

    fill_in "Paste Embed Code Here", with: '<iframe src="500.html" />'
    click_link "OK"

    expect(page).to have_css(".cke_editor_resource_content_attributes_intro_text_html") # wait focus switch finished
    save_and_check_response "Create succeeded"

    visit "/embed-test"
    expect(page).to have_css("iframe[src='500.html']")
  end
end
