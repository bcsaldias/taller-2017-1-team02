##puts
module Production
	include Queries
  	require 'json'

	def self.get_warehouses
		auth = Queries.generate_authorization
		puts auth
		@result = Queries.get("bodega/almacenes",
						  authorization=auth)
		return JSON.parse @result.body
	end

	def self.get_stock(warehouse_id, sku)
		auth = Queries.generate_authorization(_method = 'GET',
											  params = [warehouse_id,sku.to_s])
		puts auth
		@result = Queries.get(next_path="bodega/stock",
						  authorization=auth,
						  params = {almacenId:warehouse_id, sku:sku})
		return JSON.parse @result.body
	end

	def self.get_all_stock_warehouse(warehouse_id)
		auth = Queries.generate_authorization(_method = 'GET',
												params = [warehouse_id])
		#puts auth
		@result = Queries.get("bodega/skusWithStock",
						  authorization=auth,
						  params = {almacenId: warehouse_id})
		return JSON.parse @result.body
	end

	def self.move_stock(warehouse_id, product_id)

		auth = Queries.generate_authorization(_method = 'POST',
											  params = [product_id, warehouse_id])

		body = {'productoId' => product_id , 'almacenId' => warehouse_id}
		@result = Queries.post('bodega/moveStock',
							body=body, params={},
							authorization=auth)
		#puts 'testing', warehouse_id, product_id, @result.body
		return JSON.parse @result.body.force_encoding("UTF-8")
	end

	def self.move_stock_external(warehouse_id, product_id, purchase_order, price)

		auth = Queries.generate_authorization(_method = 'POST',
											  params = [product_id, warehouse_id])

		body = {'productoId' => product_id ,
				'almacenId' => warehouse_id,
			    'oc' => purchase_order,
				'precio' => price}

		@result = Queries.post('bodega/moveStockBodega',
							authorization=auth,
							body=body)

		return JSON.parse @result.body.force_encoding("UTF-8")
	end

end
