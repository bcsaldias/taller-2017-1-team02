class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      # t.references :final_product, null:false
      # t.references :needed_product, null:false

      t.string :final_product_sku, foreign_key: true, null: false
      t.string :needed_product_sku, foreign_key: true, null: false

      t.string :final_product_unit
      t.integer :requirement, null: false
      t.string :requirement_unit

      t.timestamps
    end
  end
end
