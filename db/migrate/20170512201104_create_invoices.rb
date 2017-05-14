class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :id_cloud, null: false, unique: true
      t.integer :state
      t.references :purchase_order, foreign_key: true, null: false

      t.timestamps
    end
  end
end
