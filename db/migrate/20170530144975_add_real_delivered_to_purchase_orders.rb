class AddRealDeliveredToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :true_quantity_done, :integer
  end
end
