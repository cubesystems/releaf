class CreateReleafTranslations < ActiveRecord::Migration
  def change
    create_table :releaf_i18n_entries do |t|
      t.string :key, null: false
      t.timestamps null: false
    end
    add_index :releaf_i18n_entries, :key

    create_table :releaf_i18n_entry_translations do |t|
      t.integer :i18n_entry_id, null: false
      t.string :locale, null: false, limit: 5
      t.text :text
      t.timestamps null: false
    end
    add_index :releaf_i18n_entry_translations, :locale
    add_index :releaf_i18n_entry_translations, :i18n_entry_id
    add_index :releaf_i18n_entry_translations, [:locale, :i18n_entry_id], unique: true,
      name: :index_releaf_i18n_entry_translations_on_locale_i18n_entry_id
  end
end
