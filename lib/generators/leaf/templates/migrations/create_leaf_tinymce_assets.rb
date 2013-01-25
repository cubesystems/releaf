class CreateLeafTinymceAssets < ActiveRecord::Migration
  def change
    create_table :leaf_tinymce_assets do |t|
      t.string :file_uid
      t.string :file_name

      t.timestamps
    end
  end
end
