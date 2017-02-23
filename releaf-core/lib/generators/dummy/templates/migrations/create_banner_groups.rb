class CreateBannerGroups < ActiveRecord::Migration
  def change
    create_table :banner_groups do |t|
      t.integer   :banner_page_id
      t.integer   :item_position
      t.string    :title
      t.string    :image_uid

      t.timestamps(null: false)
    end
  end
end
