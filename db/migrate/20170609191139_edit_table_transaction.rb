class EditTableTransaction < ActiveRecord::Migration[5.0]
  def change
    remove_column :transactions, :monto
    add_column :transactions, :monto, :decimal
  end
end
