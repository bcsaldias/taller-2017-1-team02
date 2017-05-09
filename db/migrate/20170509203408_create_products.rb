class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products, id: false do |t|

      t.integer :sku, null: false
      t.string :description
      t.string :category
      t.integer :price

      t.timestamps
      t.index ["sku"], name: "index_products_on_sku", unique: true
    end
  end
end
