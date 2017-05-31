class AddDeliveringToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :delivering, :boolean
  end
end
