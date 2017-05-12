class CreateSuppliers < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers, id: false  do |t|
      t.integer :id, null:false
      t.string :id_cloud
      t.string :warehouse_id
      t.string :api_prod
      t.string :api_dev

      t.timestamps
      t.index ["id"], name: "index_products_on_id", unique: true

    end
  end
end
