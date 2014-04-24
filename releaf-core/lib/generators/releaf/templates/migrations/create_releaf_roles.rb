class CreateReleafRoles < ActiveRecord::Migration
  def change
    create_table :releaf_roles do |t|
      t.string  :name,        :null => false
      t.text    :permissions
      t.string  :default_controller

      t.timestamps
    end
  end
end
