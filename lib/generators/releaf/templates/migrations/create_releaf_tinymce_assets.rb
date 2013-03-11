class CreateReleafTinymceAssets < ActiveRecord::Migration
  def change
    create_table :releaf_tinymce_assets do |t|
      t.string :file_uid
      t.string :file_name
      t.string :file_type

      t.timestamps
    end
  end
end
