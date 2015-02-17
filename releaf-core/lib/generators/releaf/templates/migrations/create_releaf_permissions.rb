class CreateReleafPermissions < ActiveRecord::Migration
  def change
    create_table :releaf_permissions do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string  :permission
      t.timestamps(null: false)
    end
    add_index :releaf_permissions, [:owner_id, :owner_type]
    add_index :releaf_permissions, :permission
  end
end
