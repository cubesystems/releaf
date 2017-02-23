class CreateBannerPages < ActiveRecord::Migration
  def change
    create_table :banner_pages do |t|
      t.text :intro_text_html
      t.string :top_banner_uid
      t.string :bottom_banner_uid      

      t.timestamps(null: false)
    end
  end
end
