class CreatePurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_orders do |t|

      t.string :id_cloud, null: false, unique: true
      t.integer :state
      t.string :product_sku, foreign_key: true, null: false
      t.string :id_store_reception
      t.string :payment_method
      t.string :cause
      t.boolean :owner
      # t.references :product, foreign_key: true, null: false

      t.timestamps
      t.index ["id_cloud"], name: "index_purchase_orders_on_id_cloud", unique: true
      
    end
  end
end
