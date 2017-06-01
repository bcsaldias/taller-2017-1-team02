class CreatedDeliveredToVoucher < ActiveRecord::Migration
  def change
    create_table :voucher_stocks do |t|
      t.string :sku, :presence => true
      t.integer :quantity, :presence => true
      t.integer :quantity_done
      
      t.references :voucher, foreign_key: true, null: false

      t.timestamps
    end
  end
end
