class CreateHomePages < ActiveRecord::Migration[5.0]
  def change
    create_table :home_pages do |t|
      t.text :intro_text_html

      t.timestamps(null: false)
    end
  end
end
