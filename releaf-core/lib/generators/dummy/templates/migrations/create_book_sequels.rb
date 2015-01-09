class CreateBookSequels < ActiveRecord::Migration
  def up
    create_table :book_sequels do |t|
      t.integer :book_id, null: false
      t.integer :sequel_id, null: false
    end

    add_index :book_sequels, [:book_id, :sequel_id], unique: true
  end

  def down
    drop_table :book_sequels
  end
end
