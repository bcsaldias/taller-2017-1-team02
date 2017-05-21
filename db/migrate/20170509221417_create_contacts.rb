class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :product, foreign_key: true
      t.references :supplier, foreign_key: true
      t.integer :priority
      t.decimal :expected_production_time
      t.integer :production_unit_cost
      t.integer :min_production_batch

      t.timestamps
    end
  end
end
