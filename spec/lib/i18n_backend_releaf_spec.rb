require "spec_helper"

describe I18n::Backend::Releaf do
  before do
    # isolate each test cases
    I18N_CACHE.clear
  end

  describe "#reload_cache" do
    it "clears translations cache" do
      I18N_CACHE.should_receive(:clear)
      I18n.backend.reload_cache
    end

    it "write last translations update timestamp to cache" do
      Settings.i18n_updated_at = Time.now
      I18n.backend.reload_cache
      expect(I18N_CACHE.read('UPDATED_AT')).to eq(Settings.i18n_updated_at)
    end

    it "load all translated data to cache" do
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

        it "reload cache" do
          I18n.backend.should_receive(:reload_cache)
          I18n.t("cancel", scope: "admin.content")
        end
      end

      context "do not differ from updates timestamp" do
        before do
          I18N_CACHE.write('UPDATED_AT', Settings.i18n_updated_at)
        end

        it "no not reload cache" do
          I18n.backend.should_not_receive(:reload_cache)
          I18n.t("cancel", scope: "admin.content")
        end
      end
    end

    context "existing translation" do
      context "in parent scope" do
        context "unexisting translation in given scope" do
          it "use parent scope" do
            translation = FactoryGirl.create(:translation, key: "blank", translation_group: FactoryGirl.create(:translation_group, scope: "validation.admin"))
            FactoryGirl.create(:translation_data, translation: translation, lang: I18n.locale, localization: "Tukšs")
            expect(I18n.t("blank", scope: "validation.admin.roles")).to eq("Tukšs")
          end
        end

        context "empty translation value in given scope" do
          it "use parent scope" do
            parent_translation = FactoryGirl.create(:translation, key: "blank", translation_group: FactoryGirl.create(:translation_group, scope: "validation.admin"))
            FactoryGirl.create(:translation_data, translation: parent_translation, lang: I18n.locale, localization: "Tukšs")

            translation = FactoryGirl.create(:translation, key: "blank", translation_group: FactoryGirl.create(:translation_group, scope: "validation.admin.roles"))
            FactoryGirl.create(:translation_data, translation: translation, lang: I18n.locale, localization: "")

            expect(I18n.t("blank", scope: "validation.admin.roles")).to eq("Tukšs")
          end
        end

        context "and existing translation value in given scope" do
          it "use given scope" do
            parent_translation = FactoryGirl.create(:translation, key: "blank", translation_group: FactoryGirl.create(:translation_group, scope: "validation.admin"))
            FactoryGirl.create(:translation_data, translation: parent_translation, lang: I18n.locale, localization: "Tukšs")

            translation = FactoryGirl.create(:translation, key: "blank", translation_group: FactoryGirl.create(:translation_group, scope: "validation.admin.roles"))
            FactoryGirl.create(:translation_data, translation: translation, lang: I18n.locale, localization: "Tukša vērtība")

            expect(I18n.t("blank", scope: "validation.admin.roles")).to eq("Tukša vērtība")
          end
        end
      end

      context "with scope" do
        it "use given scope" do
          translation = FactoryGirl.create(:translation, key: "cancel", translation_group: FactoryGirl.create(:translation_group, scope: "admin.content"))
          FactoryGirl.create(:translation_data, translation: translation, lang: I18n.locale, localization: "Atlikt")
          expect(I18n.t("cancel", scope: "admin.content")).to eq("Atlikt")
        end
      end

      context "without scope" do
        it "add default scope" do
          translation = FactoryGirl.create(:translation, translation_group: FactoryGirl.create(:translation_group, scope: "global"))
          FactoryGirl.create(:translation_data, translation: translation, lang: I18n.locale, localization: "Saglabāt")
          expect(I18n.t("save")).to eq("Saglabāt")
        end
      end
    end

    context "unexisting translation" do
      context "loading multiple times" do
        it "query db only for first time" do
          I18n.t("save", scope: "admin.global")
          I18n::Backend::Releaf::Translation.should_not_receive(:where)
          I18n.t("save", scope: "admin.global")
        end
      end

      context "without scope" do
        it "add default scope" do
          I18n.t("save")
          expect(I18n::Backend::Releaf::TranslationGroup.last.scope).to eq('global')
        end
      end

      context "with unexisting group" do
        it "create group" do
          expect { translation }.to change {  I18n::Backend::Releaf::TranslationGroup.count }.by(1)
        end

        it "create empty translation" do
          expect { translation }.to change {  I18n::Backend::Releaf::Translation.count }.by(1)
        end
      end

      context "with existing group" do
        before do
          FactoryGirl.create(:translation_group, scope: "admin.global")
        end

        it "do not create group" do
          expect { translation }.to_not change {  I18n::Backend::Releaf::TranslationGroup.count }
        end

        it "create empty translation" do
          expect { translation }.to change {  I18n::Backend::Releaf::Translation.count }.by(1)
        end
      end
    end
  end
end
