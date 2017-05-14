class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :id_cloud, null: false, unique: true
      t.integer :state
      t.references :purchase_order, foreign_key: true, null: false

      t.timestamps
      t.index ["id_cloud"], name: "index_invoices_on_id_cloud", unique: true
      
    end
  end
end
