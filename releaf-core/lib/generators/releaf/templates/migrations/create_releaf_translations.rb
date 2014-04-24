class CreateReleafTranslations < ActiveRecord::Migration
  def change
    create_table :releaf_translation_groups do |t|
      t.string :scope, :null => false
      t.timestamps
    end
    add_index :releaf_translation_groups, :scope, :unique => true


    create_table :releaf_translations do |t|
      t.integer :group_id,  :null => false
      t.string  :key,       :null => false

      t.timestamps
    end
    add_index :releaf_translations, [:group_id, :key], :unique => true
    add_index :releaf_translations, :group_id


    create_table :releaf_translation_data do |t|
      t.integer :translation_id, :null => false
      t.string :lang, :null => false, :limit => 5
      t.text :localization

      t.timestamps
    end
    add_index :releaf_translation_data, :lang
    add_index :releaf_translation_data, :translation_id
    add_index :releaf_translation_data, [:lang, :translation_id], :unique => true
  end
end
