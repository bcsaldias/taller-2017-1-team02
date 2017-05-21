class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers, id: false  do |t|
      t.integer :id, null:false
      t.string :id_cloud_dev, unique: true
      t.string :id_cloud_prod, unique: true
      t.string :warehouse_id
      t.string :api_prod
      t.string :api_dev

      t.timestamps
      t.index ["id"], name: "index_products_on_id", unique: true
      t.index ["id_cloud_dev"], name: "index_products_on_id_cloud_dev", unique: true
      t.index ["id_cloud_prod"], name: "index_products_on_id_cloud_prod", unique: true

    end
  end
end
