class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translation_groups do |t|
      t.string :scope, :null => false
      t.timestamps
    end
    add_index :translation_groups, :scope, :unique => true


    create_table :translations do |t|
      t.integer :group_id,  :null => false
      t.string  :key,       :null => false

      t.timestamps
    end
    add_index :translations, [:group_id, :key], :unique => true
    add_index :translations, :group_id


    create_table :translation_data do |t|
      t.integer :translation_id, :null => false
      t.string :lang, :null => false, :limit => 5
      t.text :localization

      t.timestamps
    end
    add_index :translation_data, :lang
    add_index :translation_data, :translation_id
    add_index :translation_data, [:lang, :translation_id], :unique => true
  end
end
