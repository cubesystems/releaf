class CreateRoles < ActiveRecord::Migration
  def change
    create_table :leaf_roles do |t|
      t.string  :name,        :null => false
      t.text    :permissions
      t.boolean :default,     :null => false, :default => false

      t.timestamps
    end
  end
end
