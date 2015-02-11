require 'spec_helper'
feature "Settings", js: true do
  scenario "edit settings" do
    values = [
      {key: "content.updated_at", default: Time.parse("2014-07-01 14:33:59")},
      {key: "content.title", default: "some"}
    ]
    Releaf::Settings.destroy_all
    Releaf::Settings.register(values)
    auth_as_user

    visit releaf_core_settings_path
    expect(page).to have_number_of_resources(2)

    search "content.updated"
    expect(page).to have_number_of_resources(1)

    click_link "content.updated_at"
    update_resource do
      fill_in 'Value', with: '2014-04-01 12:33:59'
    end

    click_link "Back to list"
    expect(page).to have_content("2014-04-01 12:33:59")

    expect(Releaf::Settings["content.updated_at"]).to eq(Time.parse("2014-04-01 12:33:59"))
  end
end
