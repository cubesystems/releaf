require 'rails_helper'
feature "Richtext editing", js: true do
  background do
    auth_as_user
  end

  scenario "Test helper fills in correct value" do
    visit new_admin_book_path
    html = %Q[ <p class="xxx" id="yyy">&quot;HTML&quot; &#39;content&#39;</p> ]
    wait_for_all_richtexts
    fill_in_richtext 'Summary', with: html
    content = evaluate_script('CKEDITOR.instances["resource_summary_html"].getData();')
    expect(content).to match_html html
  end

end
