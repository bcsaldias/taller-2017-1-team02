class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.references :final_product
      t.references :needed_product

      t.timestamps
    end
  end
end
