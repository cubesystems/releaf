require 'spec_helper'
feature "Translations" do
  background do
    auth_as_admin

    @t1 = FactoryGirl.create(:translation, key: 'test.key1')
    @t2 = FactoryGirl.create(:translation, key: 'great.stuff')
    @t3 = FactoryGirl.create(:translation, key: 'geek.stuff')

    FactoryGirl.create(:translation_data, lang: 'en', localization: 'testa atslēga', translation_id: @t1.id)
    FactoryGirl.create(:translation_data, lang: 'en', localization: 'awesome stuff', translation_id: @t2.id)
    FactoryGirl.create(:translation_data, lang: 'lv', localization: 'lieliska manta', translation_id: @t2.id)
    FactoryGirl.create(:translation_data, lang: 'en', localization: 'geek stuff', translation_id: @t3.id)
    FactoryGirl.create(:translation_data, lang: 'lv', localization: 'nūģu lieta', translation_id: @t3.id)
  end

  scenario "index" do
    visit releaf_translations_path
    expect( page ).to have_content 'test.key1'
    expect( page ).to have_content 'great.stuff'
    expect( page ).to have_content 'geek.stuff'

    expect( page ).to have_content 'testa atslēga'
    expect( page ).to have_content 'awesome stuff'
    expect( page ).to have_content 'lieliska manta'
    expect( page ).to have_content 'geek stuff'
    expect( page ).to have_content 'nūģu lieta'
  end

  scenario "Editing", js: true do
    visit releaf_translations_path

    fill_in 'search', with: "stuff"
    expect(page).to have_number_of_resources(2)
    click_link "Edit"

    within ".table tr.item:first-child" do
      expect(find_field("translations[][key]").value).to eq("geek.stuff")
      fill_in "translations[][key]", with: ""
      fill_in "translations[][localizations][lv]", with: "lv tulkojums"
      fill_in "translations[][localizations][en]", with: "en translation"
    end

    click_button "Save"
    expect(page).to have_notification("Update failed", :error)

    File.open(Rails.root.to_s + '/tmp/test.html', 'wb') { |f| f.write page.body }

    within ".table tr.item:nth-child(2)" do
      click_button "Remove item"
    end
    expect(page).to have_css(".table tr.item", count: 1) # wait for fade out to complete

    within ".table tr.item:first-child" do
      fill_in "translations[][key]", with: "great.stuff"
    end

    click_button "Save"
    expect(page).to have_notification("Update succeeded")

    # rename key
    within ".table tr.item:first-child" do
      fill_in "translations[][key]", with: "another.great.stuff"
    end
    click_button "Save"
    expect(page).to have_notification("Update succeeded")

    click_link "Back to list"
    expect(page).to have_number_of_resources(1)
    expect(page).to have_content 'lv tulkojums'
    expect(page).to have_content 'en translation'
  end

  scenario "Import excel file with translations", js: true do
    visit releaf_translations_path
    expect(page).to have_no_css(".table td span", text: "Eksports")
    expect(page).to have_no_css(".table td span", text: "Export")
    expect(page).to have_no_css(".table td span", text: "jauns")

    script = "$('form.import').css({display: 'block'});"
    page.driver.browser.execute_script(script)

    fixture_path = File.expand_path('../fixtures/translations_import.xlsx', __dir__)

    within('form.import') do
      attach_file(:import_file, fixture_path)
    end

    expect(page).to have_css(".breadcrumbs li:last-child", text: "Import")
    find(:css, 'input[name="translations[][localizations][lv]"][value="Eksports"]')
    find(:css, 'input[name="translations[][localizations][en]"][value="Export"]')

    click_button "Import"
    expect(page).to have_notification("successfuly imported 4 translations")

    visit releaf_translations_path
    expect(page).to have_css(".table td span", text: "Eksports")
    expect(page).to have_css(".table td span", text: "Export")
    expect(page).to have_css(".table td span", text: "jauns")
  end

  scenario "Export translations" do
    visit releaf_translations_path
    click_link "Export"

    expect(page.response_headers["Content-Type"]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8')

    filename = page.response_headers["Content-Disposition"].split("=")[1].gsub("\"","")
    tmp_file = Dir.tmpdir + '/' + filename
    File.open(tmp_file, "wb") { |f| f.write(page.body) }

    fixture_path = File.expand_path('../fixtures/all_translations_exported.xlsx', __dir__)
    expect(tmp_file).to match_excel(fixture_path)

    File.delete(tmp_file)
  end
end
