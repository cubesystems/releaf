class CreateBundles < ActiveRecord::Migration[5.0]
  def change
    create_table :bundles do |t|
      t.timestamps(null: false)
    end
  end
end
