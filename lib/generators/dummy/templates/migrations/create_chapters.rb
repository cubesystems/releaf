class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string  :title,        :null => false
      t.text    :text
      t.integer :book_id
      t.timestamps
    end
    add_index :chapters, :book_id
  end
end
