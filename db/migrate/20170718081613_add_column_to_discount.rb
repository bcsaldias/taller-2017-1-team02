class AddColumnToDiscount < ActiveRecord::Migration[5.0]
  def change
    add_column :discounts, :twitter_times, :integer, default: 0
    add_column :discounts, :facebook_times, :integer, default: 0
  end
end