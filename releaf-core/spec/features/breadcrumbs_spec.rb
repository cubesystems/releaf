require 'rails_helper'
feature "Breadcrumbs", js: true do
  background do
    auth_as_user
  end

  scenario "Open show view with link to resource show in breadcrumbs" do
    banner = Banner.create(url: "https://google.com")
    visit admin_banner_path(banner)

    within ".breadcrumbs" do
      expect(page).to have_css("li:last-child", text: "https://google.com")
      expect(page).to have_link("https://google.com", href: admin_banner_path(banner))
    end
  end
end
