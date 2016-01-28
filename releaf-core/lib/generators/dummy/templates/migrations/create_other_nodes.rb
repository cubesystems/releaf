class CreateOtherNodes < ActiveRecord::Migration
  def change
    create_table "other_nodes", :force => true do |t|
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
      t.text     'description'
    end
    add_index :other_nodes, :parent_id
    add_index :other_nodes, [:content_type, :content_id]
    add_index :other_nodes, :lft
    add_index :other_nodes, :rgt
    add_index :other_nodes, :depth
    add_index :other_nodes, :slug
    add_index :other_nodes, :name
    add_index :other_nodes, :active
    add_index :other_nodes, :locale
  end
end
