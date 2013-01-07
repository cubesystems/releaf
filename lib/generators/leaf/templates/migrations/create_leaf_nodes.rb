class CreateLeafNodes < ActiveRecord::Migration
  def change
    create_table "leaf_nodes", :force => true do |t|
      t.string   "name"
      t.string   "slug"
      t.integer  "parent_id"
      t.integer  "lft"
      t.integer  "rgt"
      t.string   "content_type"
      t.integer  "content_id"
      t.text     "data"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.string   "content_string"
      t.integer  "position"
      t.boolean  'visible',         :null => false, :default => true
      t.boolean  'protected',       :null => false, :default => false
    end
    add_index :leaf_nodes, :parent_id
    add_index :leaf_nodes, [:content_type, :content_id]
    add_index :leaf_nodes, :lft
    add_index :leaf_nodes, :rgt
    add_index :leaf_nodes, :slug
  end
end
