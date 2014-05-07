require "spec_helper"

describe I18n::Backend::Releaf do
  before(:all) do
    # enable empty translation creation
    Releaf.create_missing_translations = true
  end

  after(:all) do
    # disable empty translation creation
    Releaf.create_missing_translations = false
  end

  before do
    # isolate each test cases
    I18N_CACHE.clear
  end

  describe "#reload_cache" do
    it "clears translations cache" do
      I18N_CACHE.should_receive(:clear)
      I18n.backend.reload_cache
    end

    it "writes last translations update timestamp to cache" do
      Settings.i18n_updated_at = Time.now
      I18n.backend.reload_cache
      expect(I18N_CACHE.read('UPDATED_AT')).to eq(Settings.i18n_updated_at)
    end

    it "loads all translated data to cache" do
      FactoryGirl.create(:translation_data, localization: "saglabāt", lang: "lv")
      FactoryGirl.create(:translation_data, localization: "записывать", lang: "ru")

      I18n.backend.reload_cache

      expect(I18N_CACHE.read(["lv", "admin.global.save"])).to eq("saglabāt")
      expect(I18N_CACHE.read(["ru", "admin.global.save"])).to eq("записывать")
    end
  end

  describe "#lookup" do
    subject(:translation) { I18n.t("save", scope: "admin.global") }

    context "when cache timestamp" do
      context "differs from updates timestamp" do
        before do
          Settings.i18n_updated_at = Time.now
        end

        it "reloads cache" do
          I18n.backend.should_receive(:reload_cache)
          I18n.t("cancel", scope: "admin.content")
        end
      end

      context "is same as updates timestamp" do
        before do
          I18N_CACHE.write('UPDATED_AT', Settings.i18n_updated_at)
        end

        it "does not reload cache" do
          I18n.backend.should_not_receive(:reload_cache)
          I18n.t("cancel", scope: "admin.content")
        end
      end
    end

    context "existing translation" do
      context "in parent scope" do
        context "nonexistent translation in given scope" do
          it "uses parent scope" do
            translation = FactoryGirl.create(:translation, key: "validation.admin.blank")
            FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Tukšs")
            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end
        end

        context "and empty translation value in given scope" do
          it "uses parent scope" do
            parent_translation = FactoryGirl.create(:translation, key: "validation.admin.blank")
            FactoryGirl.create(:translation_data, translation: parent_translation, lang: "lv", localization: "Tukšs")

            translation = FactoryGirl.create(:translation, key: "validation.admin.roles.blank")
            FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end
        end

        context "and existing translation value in given scope" do
          it "uses given scope" do
            parent_translation = FactoryGirl.create(:translation, key: "validation.admin.blank")
            FactoryGirl.create(:translation_data, translation: parent_translation, lang: "lv", localization: "Tukšs")

            translation = FactoryGirl.create(:translation, key: "validation.admin.roles.blank")
            FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Tukša vērtība")

            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukša vērtība")
          end
        end
      end

      context "with scope" do
        it "uses given scope" do
          translation = FactoryGirl.create(:translation, key: "admin.content.cancel")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Atlikt")
          expect(I18n.t("cancel", scope: "admin.content", locale: "lv")).to eq("Atlikt")
        end
      end

      context "without scope" do
        it "adds default scope" do
          translation = FactoryGirl.create(:translation, key: "global.save")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Saglabāt")
          expect(I18n.t("save", locale: "lv")).to eq("Saglabāt")
        end
      end
    end

    context "nonexistent translation" do
      context "loading multiple times" do
        it "queries db only for the first time" do
          I18n.t("save", scope: "admin.global")
          Releaf::Translation.should_not_receive(:where)
          I18n.t("save", scope: "admin.global")
        end
      end

      context "with nonexistent translation" do
        it "creates empty translation" do
          expect { I18n.t("save") }.to change { Releaf::Translation.where(key: "global.save").count }.by(1)
        end
      end
    end
  end
end
