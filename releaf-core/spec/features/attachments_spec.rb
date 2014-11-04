require 'spec_helper'
feature "Attachments", js: true do
  background do
    # preload ActsAsNode classes
    Rails.application.eager_load!
    auth_as_user
  end

  scenario "Upload image and insert it within text" do
    visit new_releaf_content_node_path(content_type: 'Text')
    fill_in("Name", with: "Image test")

    status_script = 'CKEDITOR.instances["resource_content_attributes_text_html"].status=="ready"'
    expect { page.evaluate_script(status_script) }.to become_true

    find(".cke_toolbox a[title='Image']").click
    expect(page).to have_css(".cke_dialog_title", text: "Image Properties")
    click_link "Upload"

    within_frame(find("iframe.cke_dialog_ui_input_file")) do
      fixture_path = File.expand_path('../fixtures/cs.png', __dir__)
      attach_file(:upload, fixture_path)
    end

    click_link "Send it to the Server"
    expect(page).to have_content("Preview")
    click_link "OK"

    expect(page).to have_css(".cke_editor_resource_content_attributes_text_html") # wait focus switch finished
    save_and_check_response "Create succeeded"

    visit "/image-test"
    expect(page).to have_css("img[src='#{Releaf::Attachment.last.file.url}']")
  end

  scenario "Upload file and insert url to it" do
    visit new_releaf_content_node_path(content_type: 'Text')
    fill_in("Name", with: "Link test")

    status_script = 'CKEDITOR.instances["resource_content_attributes_text_html"].status=="ready"'
    expect { page.evaluate_script(status_script) }.to become_true

    find(".cke_toolbox a[title='Link']").click
    expect(page).to have_css(".cke_dialog_title", text: "Link")
    click_link "Upload"

    within_frame(find("iframe.cke_dialog_ui_input_file")) do
      fixture_path = File.expand_path('../fixtures/cs.png', __dir__)
      attach_file(:upload, fixture_path)
    end

    click_link "Send it to the Server"
    expect(page).to have_content("Link Type")
    click_link "OK"

    expect(page).to have_css(".cke_editor_resource_content_attributes_text_html") # wait focus switch finished
    save_and_check_response "Create succeeded"

    visit "/link-test"
    expect(page).to have_css("a[href='#{Releaf::Attachment.last.file.url}']")
  end
end
