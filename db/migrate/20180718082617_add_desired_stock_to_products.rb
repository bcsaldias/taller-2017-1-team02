class AddDesiredStockToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :desired_stock, :integer
  end
end
