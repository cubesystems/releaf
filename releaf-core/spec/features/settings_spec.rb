require 'spec_helper'
feature "Settings", js: true do
  scenario "edit settings" do
    Releaf::Settings.destroy_all
    Releaf::Settings.register_defaults("content.updated_at" => Time.parse("2014-07-01 14:33:59 +0300"), "content.title" => "some")
    auth_as_user

    visit releaf_core_settings_path
    expect(page).to have_number_of_resources(2)

    within("form.search") do
      fill_in 'search', with: "content.updated"
    end
    expect(page).to have_number_of_resources(1)

    click_link "content.updated_at"
    fill_in 'Value', with: '2014-04-01 12:33:59 +0300'
    save_and_check_response "Update succeeded"

    click_link "Back to list"
    expect(page).to have_content("2014-04-01 12:33:59 +0300")

    expect(Releaf::Settings["content.updated_at"]).to eq(Time.parse("2014-04-01 12:33:59 +0300"))
  end
end
