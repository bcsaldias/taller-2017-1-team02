class ChangePricesTwise < ActiveRecord::Migration[5.0]
  def change

    Product.all.each do |product|
      product.price = 184*2 if product.sku == "2"
      product.price = 16546*2 if product.sku == "6"
      product.price = 454*2 if product.sku == "8"
      product.price = 533*2 if product.sku == "14"
      product.price = 310*2 if product.sku == "20"
      product.price = 178*2 if product.sku == "26"
      product.price = 419*2 if product.sku == "39"
      product.price = 11470*2 if product.sku == "40"
      product.price = 9768*2 if product.sku == "41"
      product.price = 1803*2 if product.sku == "49"
      product.save!
    end

    Spree::Product.all.each do |product|
      product.price = 184*2 if product.name == "Huevo"
      product.price = 16546*2 if product.name == "Crema"
      product.price = 454*2 if product.name == "Trigo"
      product.price = 533*2 if product.name == "Cebada"
      product.price = 310*2 if product.name == "Cacao"
      product.price = 178*2 if product.name == "Sal"
      product.price = 419*2 if product.name == "Uva"
      product.price = 11470*2 if product.name == "Queso"
      product.price = 9768*2 if product.name == "Suero de Leche"
      product.price = 1803*2 if product.name == "Leche Descremada"
      product.save!
    end
  end
end

