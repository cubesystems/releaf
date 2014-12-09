require 'spec_helper'
feature "Ajaxbox", js: true do
  background do
    auth_as_user
  end

  scenario "Close ajaxbox with footer 'cancel' button without reloading page" do
    user = Releaf::Permissions::User.last
    visit releaf_permissions_users_path
    click_link user.name
    expect(page).to have_header(text: user.to_text)

    open_toolbox "Delete"
    sleep 1 # wait for form to be initialized
    click_button "No"
    expect(page).to have_header(text: user.to_text)
    expect(current_path).to eq(edit_releaf_permissions_user_path(user))
  end

  scenario "Close ajaxbox with header 'close' button without reloading page", pending: true do
  end

  scenario "Drag ajaxbox within header", pending: true do
  end

  scenario "Ajaxbox form validations", pending: true do
  end

  scenario "Ajaxbox modality (background is not clickable)", pending: true do
  end
end
