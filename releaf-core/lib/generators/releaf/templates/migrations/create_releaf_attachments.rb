class CreateReleafAttachments < ActiveRecord::Migration
  def change
    create_table :releaf_attachments, :id => false do |t|
      t.string  :uuid, :private_key => true
      t.string  :file_uid
      t.string  :file_name
      t.string  :file_type
      t.string  :richtext_attachment_type
      t.integer :richtext_attachment_id
      t.string  :title

      t.timestamps
    end

    add_index :releaf_attachments, :richtext_attachment_type
    add_index :releaf_attachments, :richtext_attachment_id
  end
end
