class ChangePrices < ActiveRecord::Migration[5.0]
  def change
    Product.all.each do |product|
      product.price = 184 if product.sku == "2"
      product.price = 16546 if product.sku == "6"
      product.price = 454 if product.sku == "8"
      product.price = 533 if product.sku == "14"
      product.price = 310 if product.sku == "20"
      product.price = 178 if product.sku == "26"
      product.price = 419 if product.sku == "39"
      product.price = 11470 if product.sku == "40"
      product.price = 9768 if product.sku == "41"
      product.price = 1803 if product.sku == "49"
      product.save!
    end
  end
end
