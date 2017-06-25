class AddColumnOwnerToDiscount < ActiveRecord::Migration[5.0]
  def change
    add_column :discounts, :owner, :boolean
  end
end