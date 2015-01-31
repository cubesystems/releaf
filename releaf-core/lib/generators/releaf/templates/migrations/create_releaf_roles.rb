class CreateReleafRoles < ActiveRecord::Migration
  def change
    create_table :releaf_roles do |t|
      t.string  :name,        :null => false
      t.string  :default_controller
      t.timestamps(null: false)
    end
  end
end
