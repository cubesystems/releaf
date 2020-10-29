class CreateAuthors < ActiveRecord::Migration[5.0]
  def change
    create_table :authors do |t|
      t.string  :name,        :null => false
      t.string  :surname
      t.text    :bio
      t.date    :birth_date
      t.string    :wiki_link
      t.integer    :publisher_id

      t.timestamps(null: false)
    end
  end
end
