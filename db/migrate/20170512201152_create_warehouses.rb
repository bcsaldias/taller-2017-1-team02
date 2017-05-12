class CreateWarehouses < ActiveRecord::Migration[5.0]
  def change
    create_table :warehouses do |t|
      t.string :id_cloud, null: false

      t.timestamps
    end
  end
end
