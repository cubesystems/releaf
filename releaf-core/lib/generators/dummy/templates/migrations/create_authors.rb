class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string  :name,        :null => false
      t.string  :surname
      t.text    :bio
      t.date    :birth_date
      t.string    :wiki_link

      t.timestamps(null: false)
    end
  end
end
