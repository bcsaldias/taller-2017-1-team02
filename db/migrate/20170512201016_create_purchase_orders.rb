class CreatePurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_orders do |t|

      t.string :id_cloud, null: false
      t.integer :state
      t.string :product_sku, foreign_key: true, null: false
      t.string :id_store_reception
      t.string :payment_method
      # t.references :product, foreign_key: true, null: false

      t.timestamps
    end
  end
end
