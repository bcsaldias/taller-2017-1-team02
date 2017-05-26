class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :id_cloud, null: false, unique: true
      t.string :cliente
      t.string :proveedor
      t.integer :bruto
      t.integer :iva  
      t.string :oc_id_cloud
      t.integer :status
      t.references :purchase_order, foreign_key: true, null: false

      t.timestamps
      t.index ["id_cloud"], name: "index_invoices_on_id_cloud", unique: true
      
    end
  end
end
