class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.text :text_html

      t.timestamps
    end

  end
end
