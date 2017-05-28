class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :id_cloud
      t.string :origen
      t.string :destino
      t.string :monto
      t.boolean :owner
      t.boolean :state

      t.timestamps null: false
    end
  end
end
