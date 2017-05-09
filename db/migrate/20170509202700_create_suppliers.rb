class CreateSuppliers < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :key, null:false
      t.string :warehouse_id
      t.string :api_prod
      t.string :api_dev
      t.integer :group_number, null:false

      t.timestamps
    end
  end
end
