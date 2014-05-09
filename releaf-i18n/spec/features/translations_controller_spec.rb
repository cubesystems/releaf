require 'spec_helper'
feature Releaf::TranslationsController do
  background do
    auth_as_admin
    @role = Releaf::Role.first

    @t1 = FactoryGirl.create(:translation, key: 'test.key1')
    @t2 = FactoryGirl.create(:translation, key: 'great.stuff')
    @t3 = FactoryGirl.create(:translation, key: 'geek.stuff')

    @t1_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'testa atslēga', translation_id: @t1.id)

    @t2_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'awesome stuff', translation_id: @t2.id)
    @t2_lv = FactoryGirl.create(:translation_data, lang: 'lv', localization: 'lieliska manta', translation_id: @t2.id)

    @t3_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'geek stuff', translation_id: @t3.id)
    @t3_lv = FactoryGirl.create(:translation_data, lang: 'lv', localization: 'nūģu lieta', translation_id: @t3.id)
  end


  describe "listing" do
    it "renders all translations", js: false do
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
  end

  it "editing", pending: 'todo' do
    visit edit_releaf_translations_path
    within "tr.translation_#{@t1.id}" do
      find(:css, 'input[name="translations[][localizations][en]"][value="testa atslēga"]')
      find(:css, 'input[name="translations[][localizations][lv]"]').fill_in('was ist das')
    end
    click_button "Save"
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
