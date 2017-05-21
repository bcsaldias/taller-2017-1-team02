class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, id: false do |t|

      # t.integer :sku, null: false
      t.string :sku, null: false
      t.string :description
      t.string :category
      t.integer :price
      t.integer :stock
      t.boolean :owner

      t.timestamps
      t.index ["sku"], name: "index_products_on_sku", unique: true
    end
  end
end
