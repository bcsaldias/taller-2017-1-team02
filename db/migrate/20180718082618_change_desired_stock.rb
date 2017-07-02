class ChangeDesiredStock < ActiveRecord::Migration[5.0]
  def change
    Product.all.each do |product|
      product.desired_stock = 600 if product.sku == "2"
      product.desired_stock = 500 if product.sku == "6"
      product.desired_stock = 1500 if product.sku == "7"
      product.desired_stock = 800 if product.sku == "8"
      product.desired_stock = 800 if product.sku == "14"
      product.desired_stock = 800 if product.sku == "20"
      product.desired_stock = 800 if product.sku == "26"
      product.desired_stock = 800 if product.sku == "39"
      product.desired_stock = 500 if product.sku == "40"
      product.desired_stock = 800 if product.sku == "41"
      product.desired_stock = 800 if product.sku == "49"
      product.save!
    end
  end
end
