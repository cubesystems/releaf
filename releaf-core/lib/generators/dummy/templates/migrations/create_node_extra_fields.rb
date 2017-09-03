class CreateNodeExtraFields < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :description, :text
  end
end
