require "rails_helper"

describe Releaf::I18nDatabase::TranslationsStore do
  describe "#initialize" do
    it "assigns updated at from `Releaf::I18nDatabase::Backend` last updated at timestamp" do
      allow(Releaf::I18nDatabase::Backend).to receive(:translations_updated_at).and_return("x")
      expect(subject.updated_at).to eq("x")
    end

    it "assigns empty hash to missing keys" do
      expect(subject.missing_keys).to eq({})
    end
  end

  describe "#config" do
    it "returns Releaf.application.config" do
      allow(Releaf.application).to receive(:config).and_return(:x)
      expect(subject.config).to eq(:x)
    end
  end

  describe "#expired?" do
    context "when last translation update differs from last cache load" do
      it "returns true" do
        allow(Releaf::I18nDatabase::Backend).to receive(:translations_updated_at).and_return(1)
        subject.updated_at = 2
        expect(subject.expired?).to be true
      end
    end

    context "when last translation update does not differ from last cache load" do
      it "returns false" do
        allow(Releaf::I18nDatabase::Backend).to receive(:translations_updated_at).and_return(1)
        subject.updated_at = 1
        expect(subject.expired?).to be false
      end
    end
  end

  describe "#exist?" do
    context "when given key exists within stored keys hash" do
      it "returns true" do
        allow(subject).to receive(:stored_keys).and_return("asd.xxx" => true)
        expect(subject.exist?("asd.xxx")).to be true
      end
    end

    context "when given key does not exist within keys hash" do
      it "returns false" do
        allow(subject).to receive(:stored_keys).and_return("asd.xxyy" => true)
        expect(subject.exist?("asd.xxx")).to be false
      end
    end
  end

  describe "#lookup" do
    it "returns first valid and returnable result" do
      allow(subject).to receive(:dig_valid_translation)
        .with(:ru, ["admin", "menu", "translations"], true, count: 23).and_return("x1")
      allow(subject).to receive(:returnable_result?)
        .with("x1", count: 23).and_return(false)

      allow(subject).to receive(:dig_valid_translation)
        .with(:ru, ["admin", "translations"], false, count: 23).and_return("x2")
      allow(subject).to receive(:returnable_result?)
        .with("x2", count: 23).and_return(true)

      expect(subject.lookup(:ru, "admin.menu.translations", count: 23)).to eq("x2")
    end

    it "iterates throught all translation scopes until last key" do
      expect(subject).to receive(:dig_valid_translation)
        .with(:ru, ["admin", "menu", "another", "translations"], true, count: 23).and_return(nil)
      expect(subject).to receive(:dig_valid_translation)
        .with(:ru, ["admin", "menu", "translations"], false, count: 23).and_return(nil)
      expect(subject).to receive(:dig_valid_translation)
        .with(:ru, ["admin", "translations"], false, count: 23).and_return(nil)
      expect(subject).to receive(:dig_valid_translation)
        .with(:ru, ["translations"], false, count: 23).and_return("x1")

      subject.lookup(:ru, "admin.menu.another.translations", count: 23)
    end

    context "when no matches found" do
      it "returns nil" do
        allow(subject).to receive(:dig_valid_translation).and_return(nil)
        expect(subject.lookup(:ru, "admin.menu.translations", count: 23)).to be nil
      end
    end
  end

  describe "#dig_translation" do
    before do
      allow(subject).to receive(:stored_translations).and_return(
        lv: {
          admin: {
            some_scope: {
              save: "Saglabāt"
            }
          }
        },
        lt: {
          public: {
            another_scope: {
              email: "E-pastas"
            }
          }
        }
      )
    end

    it "dig given locale prefixed keys hash against stored translations and returns matched value (String or Hash)" do
      expect(subject.dig_translation(:lv, [:admin, :some_scope, :save])).to eq("Saglabāt")
      expect(subject.dig_translation(:lt, [:public, :another_scope, :email])).to eq("E-pastas")
      expect(subject.dig_translation(:lt, [:public, :another_scope])).to eq(email: "E-pastas")
    end

    context "when no match found" do
      it "returns nil" do
        expect(subject.dig_translation(:lt, [:admin, :some_scope, :save])).to be nil
        expect(subject.dig_translation(:lt, [:public, :email])).to be nil
        expect(subject.dig_translation(:ge, [:public, :email])).to be nil
      end
    end
  end

  describe "#dig_valid_translation" do
    before do
      allow(subject).to receive(:dig_translation).with(:de, [:admin, :save]).and_return("translated_value")
    end

    context "when digged translation has valid result" do
      it "returns digged translation result" do
        allow(subject).to receive(:invalid_result?).with(:de, "translated_value", true, a: :b).and_return(false)
        expect(subject.dig_valid_translation(:de, [:admin, :save], true, a: :b)).to eq("translated_value")
      end
    end

    context "when digged translation has invalid result" do
      it "returns nil" do
        allow(subject).to receive(:invalid_result?).with(:de, "translated_value", true, a: :b).and_return(true)
        expect(subject.dig_valid_translation(:de, [:admin, :save], true, a: :b)).to be nil
      end
    end
  end

  describe "#invalid_result?" do
    before do
      allow(subject).to receive(:invalid_nonpluralized_result?).with("xx", true, a: :b).and_return(false)
      allow(subject).to receive(:invalid_pluralized_result?).with(:ge, "xx", a: :b).and_return(false)
    end

    context "when invalid nonplurarized result" do
      it "returns true" do
        allow(subject).to receive(:invalid_nonpluralized_result?).with("xx", true, a: :b).and_return(true)
        expect(subject.invalid_result?(:ge, "xx", true, a: :b)).to be true
      end
    end

    context "when invalid plurarized result" do
      it "returns true" do
        allow(subject).to receive(:invalid_pluralized_result?).with(:ge, "xx", a: :b).and_return(true)
        expect(subject.invalid_result?(:ge, "xx", true, a: :b)).to be true
      end
    end

    context "when no invalid nonplurarized or pluralized result" do
      it "returns false" do
        expect(subject.invalid_result?(:ge, "xx", true, a: :b)).to be false
      end
    end
  end

  describe "#invalid_nonpluralized_result?" do
    context "when hash result, not first lookup and options without count" do
      it "returns true" do
        expect(subject.invalid_nonpluralized_result?({a: :b}, false, scope: "xxx")).to be true
      end
    end

    context "when hash result, first lookup and options without count" do
      it "returns false" do
        expect(subject.invalid_nonpluralized_result?({a: :b}, true, scope: "xxx")).to be false
      end
    end

    context "when hash result, not first lookup and options with count" do
      it "returns false" do
        expect(subject.invalid_nonpluralized_result?({a: :b}, false, count: 43, scope: "xxx")).to be false
      end
    end

    context "when non hash result, not first lookup and options without count" do
      it "returns false" do
        expect(subject.invalid_nonpluralized_result?("x", false, scope: "xxx")).to be false
      end
    end
  end

  describe "#invalid_pluralized_result?" do
    before do
      allow(subject).to receive(:valid_pluralized_result?).with(:ge, 12, a: :b).and_return(false)
    end

    context "when hash result, options has count and invalid pluralized result" do
      it "returns true" do
        expect(subject.invalid_pluralized_result?(:ge, {a: :b}, {count: 12})).to be true
      end
    end

    context "when non hash result, options has count and invalid pluralized result" do
      it "returns false" do
        expect(subject.invalid_pluralized_result?(:ge, "X", {count: 12})).to be false
      end
    end

    context "when hash result, options has no count value and invalid pluralized result" do
      it "returns false" do
        expect(subject.invalid_pluralized_result?(:ge, {a: :b}, {scope: "xx.xx"})).to be false
      end
    end

    context "when hash result, options has count and valid pluralized result" do
      it "returns false" do
        allow(subject).to receive(:valid_pluralized_result?).with(:ge, 12, a: :b).and_return(true)
        expect(subject.invalid_pluralized_result?(:ge, {a: :b}, {count: 12})).to be false
      end
    end
  end

  describe "#valid_pluralized_result?" do
    context "when given hash contains valid result for given locale and count" do
      it "return true" do
        expect(subject.valid_pluralized_result?(:lv, 2, one: "x", other: "y")).to be true
      end
    end

    context "when given hash contains invalid result for given locale and count" do
      it "return false" do
        expect(subject.valid_pluralized_result?(:lv, 2, one: "x", few: "y")).to be false
      end
    end
  end

  describe "#returnable_result?" do
    context "when given result is not blank" do
      it "returns true" do
        expect(subject.returnable_result?("x", a: "b")).to be true
      end
    end

    context "when `inherit_scopes` option value is boolean `false`" do
      it "returns true" do
        expect(subject.returnable_result?(nil, inherit_scopes: false)).to be true
      end
    end

    context "when given result is blank and `inherit_scopes` option value is not boolean `false`" do
      it "returns false" do
        expect(subject.returnable_result?(nil, inherit_scopes: true)).to be false
        expect(subject.returnable_result?(nil, a: "b")).to be false
      end
    end
  end

  describe "#localization_data" do
    it "returns hash with all non empty translations with locale prefixed key and localization as value" do
      i18n_entry_1 = Releaf::I18nDatabase::I18nEntry.create(key: "some.food")
      i18n_entry_1.i18n_entry_translation.create(locale: "lv", text: "suņi")
      i18n_entry_1.i18n_entry_translation.create(locale: "en", text: "dogs")

      i18n_entry_2 = Releaf::I18nDatabase::I18nEntry.create(key: "some.good")
      i18n_entry_2.i18n_entry_translation.create(locale: "lv", text: "xx")
      i18n_entry_2.i18n_entry_translation.create(locale: "en", text: "")

      expect(subject.localization_data).to eq("lv.some.food" => "suņi", "en.some.food" => "dogs",
                                              "lv.some.good" => "xx")
    end

    it "has cached method result" do
      expect(described_class).to cache_instance_method(:localization_data)
    end
  end

  describe "#stored_keys" do
    it "returns hash with existing translation keys" do
      Releaf::I18nDatabase::I18nEntry.create(key: "some.food")
      Releaf::I18nDatabase::I18nEntry.create(key: "some.good")
      expect(subject.stored_keys).to eq("some.food" => true, "some.good" => true)
    end

    it "has cached method result" do
      expect(described_class).to cache_instance_method(:stored_keys)
    end
  end

  describe "#stored_translations" do
    it "returns deep merged hash from all key translation hashes" do
      allow(subject).to receive(:stored_keys).and_return("some.food" => true, "some.good" => true)
      allow(subject).to receive(:key_hash).with("some.food").and_return(lv: {a: "a1"}, en: {d: {e: "ee"}})
      allow(subject).to receive(:key_hash).with("some.good").and_return(lv: {b: "b2"}, en: {d: {u: "ll"}})
      expect(subject.stored_translations).to eq(lv: {a: "a1", b: "b2"}, en: {d: {e: "ee", u: "ll"}})
    end

    context "when no keys exists" do
      it "returns empty hash" do
        allow(subject).to receive(:stored_keys).and_return({})
        expect(subject.stored_translations).to eq({})
      end
    end

    it "has cached method result" do
      expect(described_class).to cache_instance_method(:stored_translations)
    end
  end

  describe "#key_hash" do
    it "build stored translation hash with keys and translated values for given key" do
      allow(subject.config).to receive(:all_locales).and_return([:ge, :de])
      allow(subject).to receive(:localization_data).and_return(
        "lv.admin.releaf_i18n_database_translations.Save" => "zc",
        "ge.admin.Save" => "asdasd",
        "de.admin.releaf_i18n_database_translations.Save" => "Seiv",
        "de.admin.releaf_i18n_database_translations.Cancel" => "dCancel",
        "ge.admin.releaf_i18n_database_translations.Cancel" => "gCancel",
      )

      expect(subject.key_hash("admin.releaf_i18n_database_translations.Save")).to eq(
        ge: {
          admin: {
            releaf_i18n_database_translations: {
              Save: nil
            }
          }
        },
        de: {
          admin: {
            releaf_i18n_database_translations: {
              Save: "Seiv"
            }
          }
        }
      )

      expect(subject.key_hash("admin.releaf_i18n_database_translations.Cancel")).to eq(
        ge: {
          admin: {
            releaf_i18n_database_translations: {
              Cancel: "gCancel"
            }
          }
        },
        de: {
          admin: {
            releaf_i18n_database_translations: {
              Cancel: "dCancel"
            }
          }
        }
      )
    end
  end

  describe "#missing?" do
    context "when given locale and key combination exists within missing keys hash" do
      it "returns true" do
        allow(subject).to receive(:missing_keys).and_return("lv.asd.xxx" => true)
        expect(subject.missing?(:lv, "asd.xxx")).to be true
      end
    end

    context "when given locale and key combination does not exist missing keys hash" do
      it "returns false" do
        allow(subject).to receive(:missing_keys).and_return("en.asd.xxx" => true)
        expect(subject.missing?(:lv, "asd.xxx")).to be false
      end
    end
  end

  describe "#missing" do
    it "adds given locale and key combination as missing" do
      expect{ subject.missing(:de, "as.pasd", a: "x") }.to change { subject.missing_keys["de.as.pasd"] }
        .from(nil).to(true)
    end

    context "when missing translation creation is available for given key and options" do
      it "creates missing translation" do
        allow(subject).to receive(:auto_create?).with("ps.asda", a: "x").and_return(true)
        expect(subject).to receive(:auto_create).with("ps.asda", a: "x")
        subject.missing(:de, "ps.asda", a: "x")
      end
    end

    context "when missing translation creation is not available for given key and options" do
      it "does not create missing translation" do
        allow(subject).to receive(:auto_create?).with("ps.asda", a: "x").and_return(false)
        expect(subject).to_not receive(:auto_create)
        subject.missing(:de, "ps.asda", a: "x")
      end
    end
  end

  describe "#auto_create?" do
    before do
      allow(subject.config.i18n_database ).to receive(:translation_auto_creation).and_return(true)
      allow(subject).to receive(:stored_keys).and_return("xxxome.save" => "xxxome.save")
      allow(subject).to receive(:auto_creation_inclusion?).with("some.save").and_return(true)
      allow(subject).to receive(:auto_creation_exception?).with("some.save").and_return(false)
    end

    context "when missing translation creation is enabled globally by i18n config and not disabled by `auto_create` option" do
      it "returns true" do
        expect(subject.auto_create?("some.save", {})).to be true
        expect(subject.auto_create?("some.save", auto_create: true)).to be true
        expect(subject.auto_create?("some.save", auto_create: nil)).to be true
      end
    end

    context "when no auto creation inclusion" do
      it "returns false" do
        allow(subject).to receive(:auto_creation_inclusion?).with("some.save").and_return(false)
        expect(subject.auto_create?("some.save", {})).to be false
      end
    end

    context "when auto creation exception" do
      it "returns false" do
        allow(subject).to receive(:auto_creation_exception?).with("some.save").and_return(true)
        expect(subject.auto_create?("some.save", {})).to be false
      end
    end

    context "when missing translation creation is disabled globally by i18n config" do
      it "returns false" do
        allow(subject.config.i18n_database ).to receive(:translation_auto_creation).and_return(false)
        expect(subject.auto_create?("some.save", {})).to be false
      end
    end

    context "when missing translation creation is disabled by `auto_create` option" do
      it "returns false" do
        expect(subject.auto_create?("some.save", auto_create: false)).to be false
      end
    end

    context "when key already exists within stored keys hash" do
      it "returns false" do
        allow(subject).to receive(:stored_keys).and_return("some.save" => "some.save")
        expect(subject.auto_create?("some.save", {})).to be false
      end
    end
  end

  describe "#auto_creation_inclusion?" do
    context "when given key matches any auto creation pattern" do
      it "returns true" do
        allow(subject.config.i18n_database ).to receive(:translation_auto_creation_patterns).and_return([/^another\./, /^some\./])
        expect(subject.auto_creation_inclusion?("some.save")).to be true
      end
    end

    context "when given key matches no auto creation pattern" do
      it "returns false" do
        allow(subject.config.i18n_database ).to receive(:translation_auto_creation_patterns).and_return([/^another\./, /^foo\./])
        expect(subject.auto_creation_inclusion?("some.save")).to be false
      end
    end
  end

  describe "#auto_creation_exception?" do
    context "when given key matches any auto creation exception pattern" do
      it "returns true" do
        allow(subject.config.i18n_database ).to receive(:translation_auto_creation_exclusion_patterns).and_return([/^another\./, /^some\./])
        expect(subject.auto_creation_exception?("some.save")).to be true
      end
    end

    context "when given key matches no auto creation exception pattern" do
      it "returns false" do
        allow(subject.config.i18n_database ).to receive(:translation_auto_creation_exclusion_patterns).and_return([/^another\./, /^foo\./])
        expect(subject.auto_creation_exception?("some.save")).to be false
      end
    end
  end

  describe "#auto_create" do
    before do
      allow(Releaf::I18nDatabase::Backend).to receive(:locales_pluralizations).and_return([:one, :many, :other])
    end

    context "when pluralizable translation given" do
      it "creates translation for each pluralization form" do
        allow(subject).to receive(:pluralizable_translation?).with(a: "b").and_return(true)
        expect(Releaf::I18nDatabase::I18nEntry).to receive(:create).with(key: "aasd.oihgja.sd.one")
        expect(Releaf::I18nDatabase::I18nEntry).to receive(:create).with(key: "aasd.oihgja.sd.many")
        expect(Releaf::I18nDatabase::I18nEntry).to receive(:create).with(key: "aasd.oihgja.sd.other")
        subject.auto_create("aasd.oihgja.sd", a: "b")
      end
    end

    context "when non pluralizable translation given" do
      it "creates translation" do
        allow(subject).to receive(:pluralizable_translation?).with(a: "b").and_return(false)
        expect(Releaf::I18nDatabase::I18nEntry).to receive(:create).with(key: "aasd.oihgja.sd")
        subject.auto_create("aasd.oihgja.sd", a: "b")
      end
    end
  end

  describe "#pluralizable_translation?" do
    context "when given options has count key and `create_plurals` key is true" do
      it "returns true" do
        expect(subject.pluralizable_translation?(count: 3, create_plurals: true)).to be true
      end
    end

    context "when given options has count key and `create_plurals` key is not true" do
      it "returns false" do
        expect(subject.pluralizable_translation?(count: 3, create_plurals: false)).to be false
        expect(subject.pluralizable_translation?(count: 3)).to be false
      end
    end

    context "when given options has no count key and `create_plurals` key is true" do
      it "returns false" do
        expect(subject.pluralizable_translation?(create_plurals: true)).to be false
      end
    end
  end
end
