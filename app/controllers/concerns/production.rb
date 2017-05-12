
module Production
	include Queries
  	
	def self.obtener_almacenes
		@result = Queries.get("bodega/almacenes", 
						  authorization=Queries.generate_authorization)
		return @result.body
	end

	def get_stock(warehouse_id, sku)

	end

end