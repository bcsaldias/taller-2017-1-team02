class AddMinBatchToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :min_batch, :integer
  end
end
