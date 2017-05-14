class CreateWarehouses < ActiveRecord::Migration[5.0]
  def change
    create_table :warehouses do |t|
      t.string :id_cloud, null: false, unique: true

      t.timestamps
      t.index ["id_cloud"], name: "index_warehouses_on_id_cloud", unique: true
      
      
    end
  end
end
