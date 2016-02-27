require 'rails_helper'
feature "Translations" do
  background(create_translations: true) do
    auth_as_user

    t1 = create(:translation, key: 'test.key1')
    t2 = create(:translation, key: 'great.stuff')
    t3 = create(:translation, key: 'geek.stuff')
    create(:translation_data, lang: 'en', localization: 'testa atslēga', translation_id: t1.id)
    create(:translation_data, lang: 'en', localization: 'awesome stuff', translation_id: t2.id)
    create(:translation_data, lang: 'lv', localization: 'lieliska manta', translation_id: t2.id)
    create(:translation_data, lang: 'en', localization: 'geek stuff', translation_id: t3.id)
    create(:translation_data, lang: 'lv', localization: 'nūģu lieta', translation_id: t3.id)
  end

  scenario "blank only filtering", js: true, create_translations: true  do
    visit releaf_i18n_database_translations_path
    expect(page).to have_number_of_resources(3)

    check "Only blank"
    expect(page).to have_number_of_resources(1)

    click_link "Edit"
    expect(page).to have_css(".table tbody.list tr", count: 1)

    within ".table tr.item:first-child" do
      fill_in "translations[][localizations][lv]", with: "lv tulkojums"
      fill_in "translations[][localizations][en]", with: "en translation"
    end
    click_button "Save"
    expect(page).to have_notification("Update succeeded")

    # TODO: fix when phantomjs will have file download implemented
    #click_link "Export"
    #filename = page.response_headers["Content-Disposition"].split("=")[1].gsub("\"","")
    #tmp_file = Dir.tmpdir + '/' + filename
    #File.open(tmp_file, "wb") { |f| f.write(page.body) }
    #fixture_path = File.expand_path('../fixtures/blank_translations_exported.xlsx', __dir__)
    #expect(tmp_file).to match_excel(fixture_path)
    #File.delete(tmp_file)

    click_link "Back to list"
    expect(page).to have_number_of_resources(0)

    uncheck "Only blank"
    expect(page).to have_number_of_resources(3)
  end

  scenario "index", create_translations: true do
    visit releaf_i18n_database_translations_path
    expect( page ).to have_content 'test.key1'
    expect( page ).to have_content 'great.stuff'
    expect( page ).to have_content 'geek.stuff'

    expect( page ).to have_content 'testa atslēga'
    expect( page ).to have_content 'awesome stuff'
    expect( page ).to have_content 'lieliska manta'
    expect( page ).to have_content 'geek stuff'
    expect( page ).to have_content 'nūģu lieta'
  end

  scenario "Editing", js: true, create_translations: true do
    visit releaf_i18n_database_translations_path

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

    within ".table tr.item:last-child" do
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

  scenario "Import excel file with translations", js: true, create_translations: true do
    visit releaf_i18n_database_translations_path
    expect(page).to have_no_css(".table td span", text: "Eksports")
    expect(page).to have_no_css(".table td span", text: "Export")
    expect(page).to have_no_css(".table td span", text: "jauns")

    script = "$('form.import').css({display: 'block'});"
    page.execute_script(script)

    fixture_path = File.expand_path('../fixtures/translations_import.xlsx', __dir__)

    within('form.import') do
      attach_file(:import_file, fixture_path)
    end

    expect(page).to have_css(".breadcrumbs li:last-child", text: "Import")
    find(:css, 'input[name="translations[][localizations][lv]"][value="Eksports"]')
    find(:css, 'input[name="translations[][localizations][en]"][value="Export"]')

    click_button "Import"
    expect(page).to have_notification("successfuly imported 4 translations")

    visit releaf_i18n_database_translations_path
    expect(page).to have_css(".table td span", text: "Eksports")
    expect(page).to have_css(".table td span", text: "Export")
    expect(page).to have_css(".table td span", text: "jauns")
  end

  scenario "Import unsupported file", js: true, create_translations: true do
    visit releaf_i18n_database_translations_path

    script = "$('form.import').css({display: 'block'});"
    page.execute_script(script)

    fixture_path = File.expand_path('../fixtures/unsupported_import_file.png', __dir__)

    within('form.import') do
      attach_file(:import_file, fixture_path)
    end

    expect(page).to have_notification("Unsupported file format", "error")
  end

  scenario "Export translations", create_translations: true do
    visit releaf_i18n_database_translations_path
    click_link "Export"

    expect(page.response_headers["Content-Type"]).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=utf-8')

    filename = page.response_headers["Content-Disposition"].split("=")[1].gsub("\"","")
    tmp_file = Dir.tmpdir + '/' + filename
    File.open(tmp_file, "wb") { |f| f.write(page.body) }

    fixture_path = File.expand_path('../fixtures/all_translations_exported.xlsx', __dir__)
    expect(tmp_file).to match_excel(fixture_path)

    File.delete(tmp_file)
  end

  describe "Lookup" do
    background do
      I18n.backend.translations_cache = nil # reset cache
      allow( Releaf.application.config.i18n_database ).to receive(:create_missing_translations).and_return(true)
    end

    context "when translation exists within higher level key (instead of being scope)" do
      it "returns nil (Humanize key)" do
        translation = create(:translation, key: "some.food")
        create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
        expect(I18n.t("some.food", locale: "lv")).to eq("suņi")
        expect(I18n.t("some.food.asd", locale: "lv")).to eq("Asd")
      end
    end

    context "when pluralized translation requested" do
      context "when valid pluralized data matched" do
        it "returns pluralized translation" do
          translation = create(:translation, key: "dog.other")
          create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("suņi")
        end
      end

      context "when invalid pluralized data matched" do
        it "returns nil (Humanize key)" do
          translation = create(:translation, key: "dog.food")
          create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("Dog")
        end
      end
    end

    context "when same translations with different cases exists" do
      it "returns case sensitive translation" do
        translation = create(:translation, key: "Save")
        create(:translation_data, translation: translation, lang: "lv", localization: "Saglabāt")

        expect(I18n.t("save", locale: "lv")).to eq("Save")
        expect(I18n.t("Save", locale: "lv")).to eq("Saglabāt")
      end
    end

    context "existing translation" do
      context "when translations hash exists in parent scope" do
        before do
          translation = create(:translation, key: "dog.other")
          create(:translation_data, translation: translation, lang: "en", localization: "dogs")
        end

        context "when pluralized translation requested" do
          it "returns pluralized translation" do
            expect(I18n.t("admin.controller.dog", count: 2)).to eq("dogs")
          end
        end

        context "when non pluralized translation requested" do
          it "returns nil" do
            expect(I18n.t("admin.controller.dog")).to eq("Dog")
          end
        end
      end

      context "when translation has default" do
        context "when default creation is disabled" do
          it "creates base translation" do
            expect{ I18n.t("xxx.test.mest", default: :"xxx.mest", create_default: false) }.to change{ Releaf::I18nDatabase::Translation.pluck(:key) }
              .to(["xxx.test.mest"])
          end
        end

        context "when default creation is not disabled" do
          it "creates base and default translations" do
            expect{ I18n.t("xxx.test.mest", default: :"xxx.mest") }.to change{ Releaf::I18nDatabase::Translation.pluck(:key) }
              .to(match_array(["xxx.mest", "xxx.test.mest"]))
          end
        end
      end

      context "in parent scope" do
        context "nonexistent translation in given scope" do
          it "uses parent scope" do
            translation = create(:translation, key: "validation.admin.blank")
            create(:translation_data, translation: translation, lang: "lv", localization: "Tukšs")
            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end

          context "when `inherit_scopes` option is `false`" do
            it "does not lookup upon higher level scopes" do
              translation = create(:translation, key: "validation.admin.blank")
              create(:translation_data, translation: translation, lang: "lv", localization: "Tukšs")
              expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv", inherit_scopes: false)).to eq("Blank")
            end
          end
        end

        context "and empty translation value in given scope" do
          it "uses parent scope" do
            parent_translation = create(:translation, key: "validation.admin.blank")
            create(:translation_data, translation: parent_translation, lang: "lv", localization: "Tukšs")

            translation = create(:translation, key: "validation.admin.roles.blank")
            create(:translation_data, translation: translation, lang: "lv", localization: "")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end
        end

        context "and existing translation value in given scope" do
          it "uses given scope" do
            parent_translation = create(:translation, key: "validation.admin.blank")
            create(:translation_data, translation: parent_translation, lang: "lv", localization: "Tukšs")

            translation = create(:translation, key: "validation.admin.roles.blank")
            create(:translation_data, translation: translation, lang: "lv", localization: "Tukša vērtība")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukša vērtība")
          end
        end
      end

      context "when scope defined" do
        it "uses given scope" do
          translation = create(:translation, key: "admin.content.cancel")
          create(:translation_data, translation: translation, lang: "lv", localization: "Atlikt")
          expect(I18n.t("cancel", scope: "admin.content", locale: "lv")).to eq("Atlikt")
        end
      end
    end

    context "nonexistent translation" do
      context "loading multiple times" do
        it "queries db only for the first time" do
          I18n.t("save", scope: "admin.xx")
          expect(Releaf::I18nDatabase::Translation).not_to receive(:where)
          I18n.t("save", scope: "admin.xx")
        end
      end

      context "with nonexistent translation" do
        before do
          allow(Releaf.application.config).to receive(:all_locales).and_return(["ru", "lv"])
        end

        it "creates empty translation" do
          expect { I18n.t("save") }.to change { Releaf::I18nDatabase::Translation.where(key: "save").count }.by(1)
        end

        context "when count option passed" do
          context "when create_plurals option not passed" do
            it "creates empty translation" do
              expect { I18n.t("animals.horse", count: 1) }.to change { Releaf::I18nDatabase::Translation.where(key: "animals.horse").count }.by(1)
            end
          end

          context "when negative create_plurals option passed" do
            it "creates empty translation" do
              expect { I18n.t("animals.horse", create_plurals: false, count: 1) }.to change { Releaf::I18nDatabase::Translation.where(key: "animals.horse").count }.by(1)
            end
          end

          context "when positive create_plurals option passed" do
            it "creates pluralized translations for all Releaf locales" do
              result = ["animals.horse.few", "animals.horse.many", "animals.horse.one", "animals.horse.other", "animals.horse.zero"]
              expect{ I18n.t("animals.horse", count: 1, create_plurals: true) }.to change{ Releaf::I18nDatabase::Translation.pluck(:key).sort }.
                from([]).to(result.sort)
            end
          end
        end
      end
    end

    context "when scope requested" do
      it "returns all scope translations" do
        translation1 = create(:translation, key: "admin.content.cancel")
        create(:translation_data, translation: translation1, lang: "lv", localization: "Atlikt")
        translation2 = create(:translation, key: "admin.content.save")
        create(:translation_data, translation: translation2, lang: "lv", localization: "Saglabāt")

        expect(I18n.t("admin.content", locale: "lv")).to eq({cancel: "Atlikt", save: "Saglabāt"})
        expect(I18n.t("admin.content", locale: "en")).to eq({cancel: nil, save: nil})
      end
    end
  end
end
