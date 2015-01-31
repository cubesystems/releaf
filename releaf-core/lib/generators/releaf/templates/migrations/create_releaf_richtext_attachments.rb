class CreateReleafRichtextAttachments < ActiveRecord::Migration
  def change
    create_table :releaf_richtext_attachments do |t|
      t.string  :file_uid
      t.string  :file_name
      t.string  :file_type
      t.string  :title

      t.timestamps
    end
  end
end
