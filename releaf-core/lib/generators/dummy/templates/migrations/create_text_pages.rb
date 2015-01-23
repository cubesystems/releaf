class CreateTextPages < ActiveRecord::Migration
  def change
    create_table :text_pages do |t|
      t.text :text_html

      t.timestamps
    end

  end
end
