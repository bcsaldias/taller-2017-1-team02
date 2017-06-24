class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|

      t.string :sku
      t.integer :precio
      t.datetime :inicio
      t.datetime :fin
      t.string :codigo, null: false, unique: true
      t.boolean :publicar
      t.timestamps
      t.integer :activation_count, default: 0
      
    end
  end
end

