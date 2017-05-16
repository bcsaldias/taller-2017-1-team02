class CreateProductionOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :production_orders do |t|

      t.string :id_cloud, null: false, unique: true
      t.string :product_sku, foreign_key: true, null: false
      t.integer :cantidad
      t.boolean :despachado, default: false
      t.datetime :disponible

      t.timestamps
      t.index ["id_cloud"], name: "index_production_orders_on_id_cloud", unique: true
      
    end
  end
end


