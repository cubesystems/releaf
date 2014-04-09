class CreateReleafNodes < ActiveRecord::Migration
  def change
    create_table "releaf_nodes", :force => true do |t|
      t.string   "name"
      t.string   "slug"
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.integer  "depth"
      t.string   "locale",          :limit => 6
      t.string   "content_type"
      t.integer  "content_id"
      t.text     "data"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "item_position"
      t.boolean  'active',          :null => false, :default => true
      t.boolean  'protected',       :null => false, :default => false
    end
    add_index :releaf_nodes, :parent_id
    add_index :releaf_nodes, [:content_type, :content_id]
    add_index :releaf_nodes, :lft
    add_index :releaf_nodes, :rgt
    add_index :releaf_nodes, :depth
    add_index :releaf_nodes, :slug
    add_index :releaf_nodes, :name
    add_index :releaf_nodes, :active
    add_index :releaf_nodes, :locale
  end
end
