class CreateBooks < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string    :title, null: false
      t.integer   :year
      t.integer   :author_id
      t.string    :genre
      t.text      :summary_html
      t.boolean   :active
      t.datetime  :published_at
      t.decimal   :price, precision: 8, scale: 2
      t.integer   :stars
      t.string    :cover_image_uid

      t.timestamps(null: false)
    end

    add_index :books, :author_id

    Book.create_translation_table! description: :string
  end

  def down
    drop_table :books
    Book.drop_translation_table!
  end
end
