class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.timestamps
    end
  end

end
