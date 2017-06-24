class AddColumnToVoucher < ActiveRecord::Migration[5.0]
  def change
    add_reference :vouchers, :discount, foreign_key: true
    add_column :vouchers, :original_value, :integer
  end
end