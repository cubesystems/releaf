class CreateHomePages < ActiveRecord::Migration
  def change
    create_table :home_pages do |t|
      t.text :intro_text_html
      t.string :banner_uid

      t.timestamps(null: false)
    end
  end
end
