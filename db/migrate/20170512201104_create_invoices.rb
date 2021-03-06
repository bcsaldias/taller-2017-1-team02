class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :id_cloud, null: false, unique: true
      t.string :cliente
      t.string :proveedor
      t.integer :bruto
      t.integer :iva  
      t.string :oc_id_cloud
      t.integer :status
      t.references :purchase_order, foreign_key: true, null: false
      t.string :cause 
      t.boolean :owner
      t.string :bank_account

      t.timestamps
      t.index ["id_cloud"], name: "index_invoices_on_id_cloud", unique: true
      
    end
  end
end
