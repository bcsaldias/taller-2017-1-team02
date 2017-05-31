class AddGroupNumberToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :group_number, :integer
    add_column :purchase_orders, :team_id_cloud, :string
  end
end
