class CreateReleafRichtextAttachments < ActiveRecord::Migration
  def change
    create_table :releaf_richtext_attachments, id: false do |t|
      t.string  :uuid, private_key: true, limit: 36
      t.string  :file_uid
      t.string  :file_name
      t.string  :file_type
      t.string  :owner_type
      t.integer :owner_id
      t.string  :title

      t.timestamps
    end

    add_index :releaf_richtext_attachments, :owner_type
    add_index :releaf_richtext_attachments, :owner_id
  end
end
