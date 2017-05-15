module Factory
	include Queries
	require 'json'
  	
	def self.get_account
	    auth = Queries.generate_authorization
        @result = Queries.get("bodega/fabrica/getCuenta", 
	    						authorization=auth)
	    return JSON.parse @result.body
	end

	def self.fabricate_without_paying(sku, cantidad)
	    auth = Queries.generate_authorization(_method = 'PUT', 
	                    params = [sku, cantidad])
	    body = {'sku' => sku , 'cantidad' => cantidad}
	    
	    @result = Queries.put('bodega/fabrica/fabricarSinPago', 
	              authorization=auth,
	              body=body)
	    puts @result
	    return JSON.parse @result.body
	end

	def self.hacer_pedido_interno(sku, cantidad)

		return false
		
		product = Product.find(sku)
		puts product
		if product.category == 'Materia prima'
			result = self.fabricate_without_paying(sku, cantidad)
			if result.keys.include?("error")
				return false
			else 
      			purchase_order = ProductionOrder.create!(id_cloud: result['_id'], 
                                        				 product_sku: result['sku'])
				return true
			end

		elsif product.category == 'Producto procesado'
			needed_products = Recipe.where(final_product_sku: product.sku)

			puts 'evaluando mover a despacho'
			needed_products.each do |recipe|
				eval_despacho = Warehouses.get_despacho_ready(recipe.needed_product_sku,
															  recipe.requirement)
				if eval_despacho
					return false
				end
			end

			puts 'materia prima disponible para producir producto procesado'
			result = self.fabricate_without_paying(sku, cantidad)
			if result.keys.include?("error")
				return false
			else 
      			purchase_order = ProductionOrder.create!(id_cloud: result['_id'], 
                                        				 product_sku: result['sku'])
      			begin
					return true
				rescue
					puts "error"
				ensure
					needed_products.each do |recipe|
						puts 'enviando solicitud de reavastecimiento', recipe.needed_product_sku, recipe.requirement
						pedido = RawMaterial.restore_stock(recipe.needed_product_sku, 
																			recipe.requirement)
					end
				end
			end

			return false
		end

	end

end