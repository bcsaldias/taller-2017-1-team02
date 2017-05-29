class AddColumnsToPurchaseOrders < ActiveRecord::Migration
  def change
    #add_column :purchase_orders, :deadline, :datetime
    add_column :purchase_orders, :unit_price, :integer
  end
end
