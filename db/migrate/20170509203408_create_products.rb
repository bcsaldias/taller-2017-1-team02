class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products, id: false do |t|

      t.integer :sku, null: false
      t.string :description
      t.string :category
      t.integer :production_unit_cost
      t.integer :price
      t.integer :min_production_batch
      t.decimal :expected_production_time
      t.references :supplier, foreign_key: true

      t.timestamps
      t.index ["sku"], name: "index_products_on_sku", unique: true
    end
  end
end
