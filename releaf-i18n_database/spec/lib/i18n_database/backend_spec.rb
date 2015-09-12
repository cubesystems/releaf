require "spec_helper"

describe Releaf::I18nDatabase::Backend do

  before do
    allow( Releaf::I18nDatabase ).to receive(:create_missing_translations).and_return(true)
    allow( I18n.backend ).to receive(:reload_cache?).and_return(true)
    I18n.backend.reload_cache
  end

  describe "#store_translations" do
    it "merges given translations to cache" do
      translation = FactoryGirl.create(:translation, key: "admin.content.save")
      FactoryGirl.create(:translation_data, translation: translation, localization: "save", lang: "en")
      FactoryGirl.create(:translation_data, translation: translation, localization: "saglabāt", lang: "lv")
      I18n.backend.reload_cache
      allow( I18n.backend ).to receive(:reload_cache?).and_return(false)

      expect{ I18n.backend.store_translations(:en, {admin: {profile: "profils"}}) }.to change{ I18n.t("admin.profile") }.
        from("Profile").to("profils")

      expect(I18n.t("admin.content.save", locale: "lv")).to eq("saglabāt")
    end
  end

  describe "#default" do
    context "when `create_default: false` option exists" do
      it "adds `create_default: true` option and remove `create_default` option" do
        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true, create_missing: false)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true, create_default: false, create_missing: false)
      end

      it "does not change given options" do
        options = {count:1, default: "xxx", fallback: true, create_default: false}
        expect{ subject.send(:default, "en", "aa", "bb", options) }.to_not change{ options }
      end
    end

    context "when `create_default: false` option does not exists" do
      it "does not modify options" do
        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true)

        expect(subject).to receive(:resolve).with("en", "aa", "bb", count: 1, fallback: true, create_default: true)
        subject.send(:default, "en", "aa", "bb", count:1, default: "xxx", fallback: true, create_default: true)
      end
    end
  end

  describe "#create_missing_translation?" do
    before do
      Releaf::I18nDatabase.create_missing_translations = true
    end

    context "when missing translation creation is enabled globally by i18n config and not disabled by `create_missing` option" do
      it "returns true" do
        expect(subject.send(:create_missing_translation?, {})).to be true
        expect(subject.send(:create_missing_translation?, create_missing: true)).to be true
        expect(subject.send(:create_missing_translation?, create_missing: nil)).to be true
      end
    end

    context "when missing translation creation is disabled globally by i18n config" do
      it "returns false" do
        allow( Releaf::I18nDatabase ).to receive(:create_missing_translations).and_return(false)
        expect(subject.send(:create_missing_translation?, {})).to be false
      end
    end

    context "when missing translation creation is disabled by `create_missing` option" do
      it "returns false" do
        expect(subject.send(:create_missing_translation?, create_missing: false)).to be false
      end
    end
  end

  describe ".translations_updated_at" do
    it "returns translations updated_at from cached settings" do
      allow(Releaf::Settings).to receive(:[]).with(described_class::UPDATED_AT_KEY).and_return("x")
      expect(described_class.translations_updated_at).to eq("x")
    end
  end

  describe ".translations_updated_at=" do
    it "stores translations updated_at to cached settings" do
      expect(Releaf::Settings).to receive(:[]=).with(described_class::UPDATED_AT_KEY, "xx")
      described_class.translations_updated_at = "xx"
    end
  end

  describe "#reload_cache?" do
    context "when last translation update differs from last cache load" do
      it "returns true" do
        allow(described_class).to receive(:translations_updated_at).and_return(1)
        described_class::CACHE[:updated_at] = 2
        expect(subject.reload_cache?).to be true
      end
    end

    context "when last translation update differs from last cache load" do
      it "returns false" do
        allow(described_class).to receive(:translations_updated_at).and_return(1)
        described_class::CACHE[:updated_at] = 1
        expect(subject.reload_cache?).to be false
      end
    end
  end

  describe "#reload_cache" do
    it "resets missing array" do
      I18n.t("something")
      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:missing].blank? }.from(false).to(true)
    end

    it "writes last translations update timestamp to cache" do
      allow(described_class).to receive(:translations_updated_at).and_return("x")
      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:updated_at] }.to("x")
    end

    it "loads all translated data to cache as hash" do
      translation = FactoryGirl.create(:translation, key: "admin.xx.save")
      FactoryGirl.create(:translation_data, translation: translation, localization: "saglabāt", lang: "lv")
      FactoryGirl.create(:translation_data, translation: translation, localization: "save", lang: "en")

      expect{ I18n.backend.reload_cache }.to change{ described_class::CACHE[:translations].blank? }.from(true).to(false)

      expect(described_class::CACHE[:translations][:lv][:admin][:xx][:save]).to eq("saglabāt")
      expect(described_class::CACHE[:translations][:en][:admin][:xx][:save]).to eq("save")
    end
  end

  describe "#lookup" do
    describe "cache reload" do
      let(:timestamp){ Time.now }

      context "when cache timestamp differs from translations update timestamp" do
        it "reloads cache" do
          described_class::CACHE[:updated_at] = timestamp
          allow(described_class).to receive(:translations_updated_at).and_return(timestamp + 1.day)
          expect(I18n.backend).to receive(:reload_cache)
          I18n.t("cancel")
        end
      end

      context "when cache timestamp is same as translations update timestamp" do
        it "does not reload cache" do
          allow( I18n.backend ).to receive(:reload_cache?).and_call_original
          described_class::CACHE[:updated_at] = timestamp
          allow(described_class).to receive(:translations_updated_at).and_return(timestamp)

          expect(I18n.backend).to_not receive(:reload_cache)
          I18n.t("cancel")
        end
      end
    end

    context "when translation exists within higher level key (instead of being scope)" do
      it "returns nil (Humanize key)" do
        translation = FactoryGirl.create(:translation, key: "some.food")
        FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "suņi")
        expect(I18n.t("some.food", locale: "lv")).to eq("suņi")
        expect(I18n.t("some.food.asd", locale: "lv")).to eq("Asd")
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
            translation = FactoryGirl.create(:translation, key: "validation.admin.blank")
            FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Tukšs")
            expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv")).to eq("Tukšs")
          end

          context "when `inherit_scopes` option is `false`" do
            it "does not lookup upon higher level scopes" do
              translation = FactoryGirl.create(:translation, key: "validation.admin.blank")
              FactoryGirl.create(:translation_data, translation: translation, lang: "lv", localization: "Tukšs")
              expect(I18n.t("blank", scope: "validation.admin.roles", locale: "lv", inherit_scopes: false)).to eq("Blank")
            end
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
          I18n.t("save", scope: "admin.xx")
          expect(Releaf::I18nDatabase::Translation).not_to receive(:where)
          I18n.t("save", scope: "admin.xx")
        end
      end

      context "with nonexistent translation" do
        before do
          allow(Releaf).to receive(:all_locales).and_return(["ru", "lv"])
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
