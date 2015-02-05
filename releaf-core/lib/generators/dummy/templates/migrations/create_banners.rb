class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.integer   :home_page_id
      t.string    :banner_uid
      t.string    :url

      t.timestamps(null: false)
    end
  end
end
