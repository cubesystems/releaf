class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.integer   :banner_group_id
      t.integer   :item_position      
      t.string    :image_uid
      t.string    :url
      t.timestamps(null: false)
    end
  end
end
