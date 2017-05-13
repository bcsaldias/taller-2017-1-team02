
module Production
	include Queries
  	
	def self.get_warehouses
		auth = Queries.generate_authorization
		@result = Queries.get("bodega/almacenes", 
						  authorization=auth)
		return @result.body
	end

	def self.get_stock(warehouse_id, sku)
		auth = Queries.generate_authorization(_method = 'GET',
											  params = [warehouse_id,sku.to_s])
		@result = Queries.get(next_path="bodega/stock", 
						  authorization=auth, 
						  params = {almacenId:warehouse_id, sku:sku})
		return @result.body
	end

	def self.get_all_stock_warehouse(warehouse_id)
		auth = Queries.generate_authorization(_method = 'GET', 
												params = [warehouse_id])

		@result = Queries.get("bodega/skusWithStock", 
						  authorization=auth, 
						  params = {almacenId: warehouse_id})
		return @result.body
	end

end