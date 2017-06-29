class ChangePricesSpree < ActiveRecord::Migration[5.0]
  def change
    Spree::Product.all.each do |product|
      product.price = 184 if product.name == "Huevo"
      product.price = 16546 if product.name == "Crema"
      product.price = 454 if product.name == "Trigo"
      product.price = 533 if product.name == "Cebada"
      product.price = 310 if product.name == "Cacao"
      product.price = 178 if product.name == "Sal"
      product.price = 419 if product.name == "Uva"
      product.price = 11470 if product.name == "Queso"
      product.price = 9768 if product.name == "Suero de Leche"
      product.price = 1803 if product.name == "Leche Descremada"
      product.save!
    end
  end
end

