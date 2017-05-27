class AddColumnsToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :deadline, :datetime
  end
end
