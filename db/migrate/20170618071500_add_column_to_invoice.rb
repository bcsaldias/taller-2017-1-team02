class AddColumnToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :transaction_id, :integer
  end
end
