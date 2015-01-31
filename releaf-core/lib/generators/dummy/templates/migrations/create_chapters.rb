class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string  :title,        :null => false
      t.text    :text
      t.text    :sample_html
      t.integer :book_id
      t.integer :item_position
      t.timestamps(null: false)
    end
    add_index :chapters, :book_id
  end
end
