class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :title
      t.string :description
      t.text :text_html

      t.timestamps
    end

  end
end
