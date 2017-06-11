 class AddQueue < ActiveRecord::Migration
  def change
    add_column :production_orders, :delivering, :boolean, default: false
    add_column :vouchers, :delivering, :boolean, default: false

    add_column :purchase_orders, :queued, :boolean, default: false
    add_column :production_orders, :queued, :boolean, default: false
    add_column :vouchers, :queued, :boolean, default: false
  end
end
