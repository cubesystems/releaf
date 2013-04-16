class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string  :title,        :null => false
      t.integer    :year
      t.integer :author_id

      t.timestamps
    end
  end
end
