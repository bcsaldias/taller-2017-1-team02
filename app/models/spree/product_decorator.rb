class DecoProd
 def self.original_products
 	Product.all.where(owner: true)
 end
end

module Spree
  
  Spree::Product.class_eval do

	  def stock
  		_p = DecoProd.original_products.find(sku)
		Spree::StockItem.where(variant_id: id).delete_all
		Spree::StockItem.create!([
		 	stock_location_id: 1, count_on_hand: _p.stock.to_i, variant_id: id,
		])
		return _p.stock || 0
	  end

  end

end