class CreateReleafTinymceAssets < ActiveRecord::Migration
  def change
    create_table :releaf_tinymce_assets do |t|
      t.string :file_uid
      t.string :file_name

      t.timestamps
    end
  end
end
