class CreatePurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_orders do |t|
      t.integer :id_cloud, null:false
      t.integer :state
      t.references :product, foreign_key: true, null: false

      t.timestamps
    end
  end
end
