class CreateReleafNodes < ActiveRecord::Migration
  def change
    create_table "nodes", :force => true do |t|
      t.string   "name"
      t.string   "slug"
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "depth"
      t.string   "locale",          :limit => 6
      t.string   "content_type"
      t.integer  "content_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "item_position"
      t.boolean  'active',          :null => false, :default => true
    end
    add_index :nodes, :parent_id
    add_index :nodes, [:content_type, :content_id]
    add_index :nodes, :lft
    add_index :nodes, :rgt
    add_index :nodes, :depth
    add_index :nodes, :slug
    add_index :nodes, :name
    add_index :nodes, :active
    add_index :nodes, :locale
  end
end
