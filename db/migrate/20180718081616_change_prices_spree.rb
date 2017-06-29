class ChangePricesSpree < ActiveRecord::Migration[5.0]
  def change
    Spree::Product.all.each do |product|
      product.price = 184 if product.name == "Huevo"
      product.price = 16546 if product.name == "Crema"
      product.price = 454 if product.sku == "Trigo"
      product.price = 533 if product.sku == "Cebada"
      product.price = 310 if product.sku == "Cacao"
      product.price = 178 if product.sku == "Sal"
      product.price = 419 if product.sku == "Uva"
      product.price = 11470 if product.sku == "Queso"
      product.price = 9768 if product.sku == "Suero de Leche"
      product.price = 1803 if product.sku == "Leche Descremada"
      product.save!
    end
  end
end

