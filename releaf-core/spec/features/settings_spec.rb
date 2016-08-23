require 'rails_helper'
feature "Settings", js: true do
  scenario "edit settings" do
    values = [
      {key: "content.updated_at", default: Time.parse("2014-07-01 14:33:59"), description: "Content update time", type: :time},
      {key: "content.updated", default: true, description: "Content is updated?", type: :boolean},
      {key: "content.rating", default: 5.65, type: :decimal},
      {key: "content.title", default: "some"},
      {key: "content.date", default: DateTime.parse("2015-05-02"), type: "date"}
    ]
    Releaf::Settings.destroy_all
    Releaf::Settings.register(*values)
    auth_as_user

    visit releaf_settings_path
    expect(page).to have_number_of_resources(5)
    expect(page).to have_css(".table.releaf\\/settings tbody tr:first-child td:first-child", text: "content.date")
    expect(page).to have_css(".table.releaf\\/settings tbody tr:first-child td:nth-child(2)", text: /^2015-05-02$/)
    expect(page).to have_css(".table.releaf\\/settings tbody tr:last-child td:first-child", text: "content.updated_at")

    search "content.updated"
    expect(page).to have_number_of_resources(2)

    click_link "content.updated_at"
    update_resource do
      fill_in "Content update time", with: '2014-04-01 12:33:59'
    end

    click_link "Back to list"
    expect(page).to have_content("2014-04-01 12:33:59")
    expect(Releaf::Settings["content.updated_at"]).to eq(Time.parse("2014-04-01 12:33:59"))

    click_link "content.updated"
    expect(page).to have_field("Content is updated?")
    expect(page).to have_css(".field input[type='checkbox'][checked='checked']")

    visit releaf_settings_path

    click_link "content.rating"
    expect(page).to have_field("Value")
    expect(page).to have_css(".field input[type='number'][value='5.65']")
  end
end
