require 'rails_helper'
feature "Translations" do
  background(create_translations: true) do
    auth_as_user

    translation_1 = Releaf::I18nDatabase::I18nEntry.create(key: 'test.key1')
    translation_2 = Releaf::I18nDatabase::I18nEntry.create(key: 'great.stuff')
    translation_3 = Releaf::I18nDatabase::I18nEntry.create(key: 'geek.stuff')
    translation_1.i18n_entry_translation.create(locale: 'en', text: 'testa atslēga')
    translation_2.i18n_entry_translation.create(locale: 'en', text: 'awesome stuff')
    translation_2.i18n_entry_translation.create(locale: 'lv', text: 'lieliska manta')
    translation_3.i18n_entry_translation.create(locale: 'en', text: 'geek stuff')
    translation_3.i18n_entry_translation.create(locale: 'lv', text: 'nūģu lieta')
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
      click_button "Remove"
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

  scenario "Do not save empty translations", create_translations: true do
    visit releaf_i18n_database_translations_path
    click_link "Edit"
    click_button "Save"

    expect(Releaf::I18nDatabase::I18nEntryTranslation.where(text: "").count).to eq(0)
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

  scenario "Import corrupt xls file", js: true, create_translations: true do
    visit releaf_i18n_database_translations_path

    script = "$('form.import').css({display: 'block'});"
    page.execute_script(script)

    fixture_path = File.expand_path('../fixtures/invalid.xls', __dir__)

    within('form.import') do
      attach_file(:import_file, fixture_path)
    end

    expect(page).to have_notification("Unsupported file format", "error")
  end


  scenario "Import corrupt xlsx file", js: true, create_translations: true do
    visit releaf_i18n_database_translations_path

    script = "$('form.import').css({display: 'block'});"
    page.execute_script(script)

    fixture_path = File.expand_path('../fixtures/invalid.xlsx', __dir__)

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
      Releaf::I18nDatabase::Backend.reset_cache
      allow( Releaf.application.config.i18n_database ).to receive(:translation_auto_creation).and_return(true)
    end

    context "when translation exists within higher level key (instead of being scope)" do
      it "returns nil (Humanize key)" do
        translation = Releaf::I18nDatabase::I18nEntry.create(key: "some.food")
        translation.i18n_entry_translation.create(locale: "lv", text: "suņi")

        expect(I18n.t("some.food", locale: "lv")).to eq("suņi")
        expect(I18n.t("some.food.asd", locale: "lv")).to eq("Asd")
      end
    end

    context "when pluralized translation requested" do
      context "when valid pluralized data matched" do
        it "returns pluralized translation" do
          translation = Releaf::I18nDatabase::I18nEntry.create(key: "dog.other")
          translation.i18n_entry_translation.create(locale: "lv", text: "suņi")

          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("suņi")
        end
      end

      context "when invalid pluralized data matched" do
        it "returns nil (Humanize key)" do
          translation = Releaf::I18nDatabase::I18nEntry.create(key: "dog.food")
          translation.i18n_entry_translation.create(locale: "lv", text: "suņi")

          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("Dog")
        end
      end
    end

    context "when same translations with different cases exists" do
      it "returns case sensitive translation" do
        translation = Releaf::I18nDatabase::I18nEntry.create(key: "Save")
        translation.i18n_entry_translation.create(locale: "lv", text: "Saglabāt")

        expect(I18n.t("save", locale: "lv")).to eq("Save")
        expect(I18n.t("Save", locale: "lv")).to eq("Saglabāt")
      end
    end

    context "existing translation" do
      context "when translations hash exists in parent scope" do
        before do
          translation = Releaf::I18nDatabase::I18nEntry.create(key: "dog.other")
          translation.i18n_entry_translation.create(locale: "en", text: "dogs")
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

      context "when ignorable pattern" do
        it "does not auto create missing translation" do
          expect{ I18n.t("attributes.title") }.to_not change{ Releaf::I18nDatabase::I18nEntry.count }
        end
      end

      context "in parent scope" do
        context "nonexistent translation in given scope" do
          it "uses parent scope" do
            translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.blank")
            translation.i18n_entry_translation.create(locale: "lv", text: "Tukšs")
            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end

          context "when `inherit_scopes` option is `false`" do
            it "does not lookup upon higher level scopes" do
              translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.blank")
              translation.i18n_entry_translation.create(locale: "lv", text: "Tukšs")
              expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv", inherit_scopes: false)).to eq("Blank")
            end
          end
        end

        context "and empty translation value in given scope" do
          it "uses parent scope" do
            translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.roles.blank")
            translation.i18n_entry_translation.create(locale: "lv", text: "")

            parent_translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.blank")
            parent_translation.i18n_entry_translation.create(locale: "lv", text: "Tukšs")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end
        end

        context "and existing translation value in given scope" do
          it "uses given scope" do
            translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.roles.blank")
            translation.i18n_entry_translation.create(locale: "lv", text: "Tukša vērtība")

            parent_translation = Releaf::I18nDatabase::I18nEntry.create(key: "validation.admin.blank")
            parent_translation.i18n_entry_translation.create(locale: "lv", text: "Tukšs")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukša vērtība")
          end
        end
      end

      context "when scope defined" do
        it "uses given scope" do
          translation = Releaf::I18nDatabase::I18nEntry.create(key: "admin.content.cancel")
          translation.i18n_entry_translation.create(locale: "lv", text: "Atlikt")
          expect(I18n.t("cancel", scope: "admin.content", locale: "lv")).to eq("Atlikt")
        end
      end
    end

    context "nonexistent translation" do
      context "loading multiple times" do
        it "queries db only for the first time" do
          I18n.t("save", scope: "admin.xx")
          expect(Releaf::I18nDatabase::I18nEntry).not_to receive(:where)
          I18n.t("save", scope: "admin.xx")
        end
      end

      context "with nonexistent translation" do
        before do
          allow(Releaf.application.config).to receive(:all_locales).and_return(["ru", "lv"])
          allow(I18n).to receive(:locale_available?).and_return(true)
        end

        it "creates empty translation" do
          expect { I18n.t("save") }.to change { Releaf::I18nDatabase::I18nEntry.where(key: "save").count }.by(1)
        end

        context "when count option passed" do
          context "when create_plurals option not passed" do
            it "creates empty translation" do
              expect { I18n.t("animals.horse", count: 1) }.to change { Releaf::I18nDatabase::I18nEntry.where(key: "animals.horse").count }.by(1)
            end
          end

          context "when negative create_plurals option passed" do
            it "creates empty translation" do
              expect { I18n.t("animals.horse", create_plurals: false, count: 1) }.to change { Releaf::I18nDatabase::I18nEntry.where(key: "animals.horse").count }.by(1)
            end
          end

          context "when positive create_plurals option passed" do
            it "creates pluralized translations for all Releaf locales" do
              result = ["animals.horse.few", "animals.horse.many", "animals.horse.one", "animals.horse.other", "animals.horse.zero"]
              expect{ I18n.t("animals.horse", count: 1, create_plurals: true) }.to change{ Releaf::I18nDatabase::I18nEntry.pluck(:key).sort }.
                from([]).to(result.sort)
            end
          end
        end
      end
    end

    context "when scope requested" do
      it "returns all scope translations" do
        translation_1 = Releaf::I18nDatabase::I18nEntry.create(key: "admin.content.cancel")
        translation_1.i18n_entry_translation.create(locale: "lv", text: "Atlikt")

        translation_2 = Releaf::I18nDatabase::I18nEntry.create(key: "admin.content.save")
        translation_2.i18n_entry_translation.create(locale: "lv", text: "Saglabāt")

        expect(I18n.t("admin.content", locale: "lv")).to eq(cancel: "Atlikt", save: "Saglabāt")
        expect(I18n.t("admin.content", locale: "en")).to eq(cancel: nil, save: nil)
      end
    end
  end


  describe "pluralization" do

    before do
      locales = [:lv, :ru]
      allow(I18n.config).to receive(:available_locales).and_return(locales)
      allow(Releaf.application.config).to receive(:available_locales).and_return(locales)
      allow(Releaf.application.config).to receive(:all_locales).and_return(locales)

      I18n.reload!

      [:few, :many, :one, :other, :zero].each do |rule|
        translation = Releaf::I18nDatabase::I18nEntry.create!(key: "public.years.#{rule}")
        locales.each do |locale|
          translation.i18n_entry_translation.create!( locale: locale.to_s, text: "years #{locale} #{rule} XX" )
        end
      end

      Releaf::I18nDatabase::Backend.reset_cache
    end

    after do
      # force I18n reloading to restore the original state.
      # for this to work, the stubs must be removed beforehand
      allow(I18n.config).to receive(:available_locales).and_call_original
      allow(Releaf.application.config).to receive(:available_locales).and_call_original
      allow(Releaf.application.config).to receive(:all_locales).and_call_original
      I18n.reload!
    end

    it "uses rails-i18n pluralization mechanism to detect correct pluralization keys" do
      expect(I18n.t("years", scope: "public", count: 0, locale: :lv)).to eq 'years lv zero XX'
      expect(I18n.t("years", scope: "public", count: 1, locale: :lv)).to eq 'years lv one XX'
      expect(I18n.t("years", scope: "public", count: 3, locale: :lv)).to eq 'years lv other XX'

      expect(I18n.t("years", scope: "public", count: 1, locale: :ru)).to eq 'years ru one XX'
      expect(I18n.t("years", scope: "public", count: 3, locale: :ru)).to eq 'years ru few XX'
      expect(I18n.t("years", scope: "public", count: 5, locale: :ru)).to eq 'years ru many XX'
    end

  end


end
