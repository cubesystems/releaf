require "spec_helper"

describe Releaf::I18nDatabase::Backend do
  before(:all) do
    # enable empty translation creation
    Releaf::I18nDatabase.create_missing_translations = true
  end

  after(:all) do
    # disable empty translation creation
    Releaf::I18nDatabase.create_missing_translations = false
  end

  before do
    # isolate each test cases
    I18n.backend.reload_cache
    described_class::CACHE[:updated_at] = nil
  end

  describe "#store_translations" do
    it "merges given translations to cache" do
      translation = FactoryGirl.create(:translation, key: "admin.content.save")
      FactoryGirl.create(:translation_data, translation: translation, localization: "save", lang: "en")
      FactoryGirl.create(:translation_data, translation: translation, localization: "saglabāt", lang: "lv")

      expect{ I18n.backend.store_translations(:en, {admin: {profile: "profils"}}) }.to change{ I18n.t("admin.profile") }.
        from("Profile").to("profils")

      expect(I18n.t("admin.content.save", locale: "lv")).to eq("saglabāt")
    end
  end

  describe ".translations_updated_at" do
    it "returns translations updated_at" do
      Settings['releaf.i18n_database.translations.updated_at'] = Time.now
      expect(described_class.translations_updated_at).to eq(Settings['releaf.i18n_database.translations.updated_at'])
    end
  end

  describe ".translations_updated_at=" do
    it "stores translations updated_at" do
      expect{ described_class.translations_updated_at = "xx" }.to change{ Settings['releaf.i18n_database.translations.updated_at'] }.
        to("xx")
    end
  end

  describe "#reload_cache?" do
    context "when last translation update differs from last cache load" do
      it "returns true" do
        described_class.stub(:translations_updated_at).and_return(1)
        described_class::CACHE[:updated_at] = 2
        expect(subject.reload_cache?).to be_true
      end
    end

    context "when last translation update differs from last cache load" do
      it "returns false" do
        described_class.stub(:translations_updated_at).and_return(1)
        described_class::CACHE[:updated_at] = 1
        expect(subject.reload_cache?).to be_false
      end
    end
  end

  describe "#reload_cache" do
    it "resets missing array" do
      I18n.t("something")
      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:missing].blank? }.from(false).to(true)
    end

    it "writes last translations update timestamp to cache" do
      described_class.stub(:translations_updated_at).and_return("x")
      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:updated_at] }.to("x")
    end

    it "loads all translated data to cache as hash" do
      translation = FactoryGirl.create(:translation, key: "admin.global.save")
      FactoryGirl.create(:translation_data, translation: translation, localization: "saglabāt", lang: "lv")
      FactoryGirl.create(:translation_data, translation: translation, localization: "save", lang: "en")

      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:translations].blank? }.from(true).to(false)

      expect(described_class::CACHE[:translations][:lv][:admin][:global][:save]).to eq("saglabāt")
      expect(described_class::CACHE[:translations][:en][:admin][:global][:save]).to eq("save")
    end
  end

  describe "#lookup" do
    describe "cache reload" do
      let(:timestamp){ Time.now }

      context "when cache timestamp differs from translations update timestamp" do
        it "reloads cache" do
          described_class::CACHE[:updated_at] = timestamp
          described_class.stub(:translations_updated_at).and_return(timestamp + 1.day)
          expect(I18n.backend).to receive(:reload_cache)
          I18n.t("cancel")
        end
      end

      context "when cache timestamp is same as translations update timestamp" do
        it "does not reload cache" do
          described_class::CACHE[:updated_at] = timestamp
         described_class.stub(:translations_updated_at).and_return(timestamp)

          expect(I18n.backend).to_not receive(:reload_cache)
          I18n.t("cancel")
        end
      end
    end

    context "when pluralized translation requested" do
      context "when valid pluralized data matched" do
        it "returns pluralized translation" do
          translation = FactoryGirl.create(:translation, key: "dog.other")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("suņi")
        end
      end

      context "when invalid pluralized data matched" do
        it "returns nil (Humanize key)" do
          translation = FactoryGirl.create(:translation, key: "dog.food")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
          expect(I18n.t("dog", locale: "lv", count: 2)).to eq("Dog")
        end
      end
    end

    context "existing translation" do
      context "when translation exists with different case" do
        it "returns existing translation" do
          translation = FactoryGirl.create(:translation, key: "Save")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Saglabāt")
          I18n.backend.reload_cache

          expect(I18n.t("save", locale: "lv")).to eq("Saglabāt")
          expect(I18n.t("Save", locale: "lv")).to eq("Saglabāt")
        end
      end

      context "when translations hash exists in parent scope" do
        before do
          translation = FactoryGirl.create(:translation, key: "dog.other")
          FactoryGirl.create(:translation_data, translation: translation, lang: "en", localization: "dogs")
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

      context "when scope defined" do
        it "uses given scope" do
          translation = FactoryGirl.create(:translation, key: "admin.content.cancel")
          FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Atlikt")
          expect(I18n.t("cancel", scope: "admin.content", locale: "lv")).to eq("Atlikt")
        end
      end
    end

    context "nonexistent translation" do
      context "loading multiple times" do
        it "queries db only for the first time" do
          I18n.t("save", scope: "admin.global")
          Releaf::I18nDatabase::Translation.should_not_receive(:where)
          I18n.t("save", scope: "admin.global")
        end
      end

      context "with nonexistent translation" do
        before do
          Releaf.stub(:all_locales).and_return(["ru", "lv"])
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
              result = ["animals.horse.many", "animals.horse.one", "animals.horse.other", "animals.horse.zero"]
              expect{ I18n.t("animals.horse", count: 1, create_plurals: true) }.to change{ Releaf::I18nDatabase::Translation.pluck(:key) }.
                from([]).to(result)
            end
          end
        end
      end
    end

    context "when scope requested" do
      it "returns all scope translations" do
        translation1 = FactoryGirl.create(:translation, key: "admin.content.cancel")
        FactoryGirl.create(:translation_data, translation: translation1, lang: "lv", localization: "Atlikt")
        translation2 = FactoryGirl.create(:translation, key: "admin.content.save")
        FactoryGirl.create(:translation_data, translation: translation2, lang: "lv", localization: "Saglabāt")

        expect(I18n.t("admin.content", locale: "lv")).to eq({cancel: "Atlikt", save: "Saglabāt"})
        expect(I18n.t("admin.content", locale: "en")).to eq({cancel: nil, save: nil})
      end
    end
  end
end
