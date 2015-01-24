class CreateNodeExtraFields < ActiveRecord::Migration
  def change
    add_column :nodes, :description, :text
  end
end
