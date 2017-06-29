class DecoProd
 def self.original_products
 	Product.where(owner: true)
 end
end

module Spree
  
  Spree::Product.class_eval do

	  def stock
  		_p = DecoProd.original_products.find(sku)
		#Spree::StockItem.where(variant_id: id).delete_all
		price = _p.price
		save!
		###
		### Actualizar con stock disponible.
		### El stock reservado tiene que ver todas las OC no completadas.
		###
		Spree::StockItem.where(variant_id: id).delete_all
		Spree::StockItem.create!([
		 	stock_location_id: 1, count_on_hand: _p.stock_disponible.to_i, variant_id: id,
		])
		return _p.stock_disponible || 0
	  end

  end

end