class CreatePublishers < ActiveRecord::Migration[5.0]
  def change
    create_table :publishers do |t|
      t.string  :title,        :null => false
      t.timestamps(null: false)
    end
  end
end
