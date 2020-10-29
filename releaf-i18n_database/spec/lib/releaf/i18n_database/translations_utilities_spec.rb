require "rails_helper"

describe Releaf::I18nDatabase::TranslationsUtilities do
  def postgresql?
    ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  end

  describe ".search" do
    before do
      allow(described_class).to receive(:filter_by_text).with("aaa", "xxxx").and_return("bbb")
      allow(described_class).to receive(:filter_only_blank_translations).with("bbb").and_return("ccc")
      allow(described_class).to receive(:filter_only_blank_translations).with("ddd").and_return("eee")
    end

    context "when search string is present" do
      it "applies search filter to given collection" do
        expect(described_class.search("aaa", "xxxx", true)).to eq("ccc")
      end
    end

    context "when search string is empty" do
      it "does not apply search filter to given collection" do
        expect(described_class.search("ddd", "", true)).to eq("eee")
      end
    end

    context "when `only blank` option is true" do
      it "applies `only blank` filter to given collection" do
        expect(described_class.search("aaa", "xxxx", true)).to eq("ccc")
      end
    end

    context "when `only blank` option is other than true" do
      it "does not apply `only blank` filter to given collection" do
        expect(described_class.search("aaa", "xxxx", false)).to eq("bbb")
      end
    end
  end

  describe ".filter_only_blank_translations" do
    it "returns given collection applied with empty translation data search" do
      collection = Releaf::I18nDatabase::I18nEntry.where("id > 1")
      allow(described_class).to receive(:search_columns).and_return([
        Releaf::I18nDatabase::I18nEntry.arel_table[:key],
        Releaf::I18nDatabase::I18nEntry.arel_table.alias("lv_data")[:text],
      ])
      if postgresql?
        result = "WHERE (id > 1) AND ((\"releaf_i18n_entries\".\"key\" = '' OR \"releaf_i18n_entries\".\"key\" IS NULL)"
        result += " OR (\"lv_data\".\"text\" = '' OR \"lv_data\".\"text\" IS NULL))"
      else
        result = "WHERE (id > 1) AND ((`releaf_i18n_entries`.`key` = '' OR `releaf_i18n_entries`.`key` IS NULL)"
        result += " OR (`lv_data`.`text` = '' OR `lv_data`.`text` IS NULL))"
      end
      expect(described_class.filter_only_blank_translations(collection).to_sql).to end_with(result)
    end
  end

  describe ".filter_by_text" do
    it "returns collection with grouped column searches" do
      collection = Releaf::I18nDatabase::I18nEntry.where("id > 1")
      allow(described_class).to receive(:column_searches).with("redx").and_return([
        "id = 8 AND id = 2",
        "id = 9 AND id = 19",
      ])
      result = "WHERE (id > 1) AND ((id = 8 AND id = 2) OR (id = 9 AND id = 19))"
      expect(described_class.filter_by_text(collection, "redx").to_sql).to end_with(result)
    end
  end

  describe ".column_searches" do
    it "return array with column based searches" do
      allow(described_class).to receive(:search_columns).and_return([
        Releaf::I18nDatabase::I18nEntry.arel_table[:key],
        Releaf::I18nDatabase::I18nEntry.arel_table.alias("lv_data")[:text],
      ])
      allow(described_class).to receive(:escape_search_string).with("red").twice.and_return("escaped_red")
      allow(described_class).to receive(:escape_search_string).with("car").twice.and_return("escaped_car")
      if postgresql?
        result = ["\"releaf_i18n_entries\".\"key\" ILIKE '%escaped_red%' AND \"releaf_i18n_entries\".\"key\" ILIKE '%escaped_car%'",
                  "\"lv_data\".\"text\" ILIKE '%escaped_red%' AND \"lv_data\".\"text\" ILIKE '%escaped_car%'"]
      else
        result = ["`releaf_i18n_entries`.`key` LIKE '%escaped_red%' AND `releaf_i18n_entries`.`key` LIKE '%escaped_car%'",
                  "`lv_data`.`text` LIKE '%escaped_red%' AND `lv_data`.`text` LIKE '%escaped_car%'"]
      end
      expect(described_class.column_searches(" red   car ")).to eq(result)
    end
  end

  describe ".search_columns" do
    it "returns array with translation key arel attribute and locale tables localization attributes" do
      allow(described_class).to receive(:locale_tables).and_return(
        de: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("de_data"),
        lv: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("lv_data"),
        en: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("en_data")
      )

      result = [
        Releaf::I18nDatabase::I18nEntry.arel_table[:key],
        Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("de_data")[:text],
        Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("lv_data")[:text],
        Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("en_data")[:text]
      ]
      expect(described_class.search_columns).to eq(result)
    end
  end

  describe ".escape_search_string" do
    it "returns escaped search string with escaped `%` and `_` chars" do
      expect(described_class.escape_search_string("k %  _ x")).to eq("k \\%  \\_ x")
    end
  end

  describe ".locale_tables" do
    it "returns array with arel aliased locale tables" do
      allow(Releaf.application.config).to receive(:all_locales).and_return([:de, :en])
      result = {
        de: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("de_data"),
        en: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("en_data")
      }
      expect(described_class.locale_tables).to eq(result)
    end
  end

  describe ".include_localizations" do
    it "returns given collection with included joins and overrided selects" do
      allow(described_class).to receive(:localization_include_joins).and_return(["a", "b"])
      allow(described_class).to receive(:localization_include_selects).and_return("x")
      if postgresql?
        result = "SELECT x FROM \"releaf_i18n_entries\" a b"
      else
        result = "SELECT x FROM `releaf_i18n_entries` a b"
      end
      expect(described_class.include_localizations(Releaf::I18nDatabase::I18nEntry).to_sql).to eq(result)
    end
  end

  describe ".localization_include_joins" do
    it "returns array with locales translation table joins" do
      allow(described_class).to receive(:locale_tables).and_return(
        de: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("de_data"),
        lv: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("lv_data"),
        en: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("en_data")
      )
      result = ["LEFT JOIN releaf_i18n_entry_translations AS de_data ON de_data.i18n_entry_id = releaf_i18n_entries.id AND de_data.locale = 'de'",
                "LEFT JOIN releaf_i18n_entry_translations AS lv_data ON lv_data.i18n_entry_id = releaf_i18n_entries.id AND lv_data.locale = 'lv'",
                "LEFT JOIN releaf_i18n_entry_translations AS en_data ON en_data.i18n_entry_id = releaf_i18n_entries.id AND en_data.locale = 'en'"]
      expect(described_class.localization_include_joins).to eq(result)
    end
  end

  describe ".localization_include_selects" do
    it "returns all base table columns and each locale translated values and ids" do
      allow(described_class).to receive(:localization_include_locales_columns).and_return([
        "de_data.localization AS de_localization",
        "de_data.id AS de_localization_id"
      ])
      result = "releaf_i18n_entries.*, de_data.localization AS de_localization, de_data.id AS de_localization_id"
      expect(described_class.localization_include_selects).to eq(result)
    end
  end

  describe ".localization_include_locales_columns" do
    it "returns locales translated values columns and ids" do
      allow(described_class).to receive(:locale_tables).and_return(
        de: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("de_data"),
        lv: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("lv_data"),
        en: Releaf::I18nDatabase::I18nEntryTranslation.arel_table.alias("en_data")
      )
      result = ["de_data.text AS de_localization", "de_data.id AS de_localization_id",
                "lv_data.text AS lv_localization", "lv_data.id AS lv_localization_id",
                "en_data.text AS en_localization", "en_data.id AS en_localization_id"]
      expect(described_class.localization_include_locales_columns).to eq(result)
    end
  end
end
