class AddMinBatchValuesToProducts < ActiveRecord::Migration[5.0]
  def change
    Product.all.each do |p|
      p.min_batch = 150 if p.sku == "2"
      p.min_batch = 30 if p.sku == "6"
      p.min_batch = 100 if p.sku == "8"
      p.min_batch = 1750 if p.sku == "14"
      p.min_batch = 60 if p.sku == "20"
      p.min_batch = 144 if p.sku == "26"
      p.min_batch = 250 if p.sku == "39"
      p.min_batch = 900 if p.sku == "40"
      p.min_batch = 200 if p.sku == "41"
      p.min_batch = 200 if p.sku == "49"
      p.save!
    end
  end
end
