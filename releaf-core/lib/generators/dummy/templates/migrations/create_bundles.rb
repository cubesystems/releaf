class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.timestamps(null: false)
    end
  end
end
