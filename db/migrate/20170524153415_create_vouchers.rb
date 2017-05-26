class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :id_cloud
      t.string :spree_order_id
      t.string :client
      t.string :address
      t.integer :bruto
      t.integer :iva
      t.string :oc_id_cloud
      t.string :status

      t.timestamps null: false
    end
  end
end
 