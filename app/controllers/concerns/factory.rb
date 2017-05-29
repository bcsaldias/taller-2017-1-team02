module Factory
	include Queries
	require 'json'
  	
	def self.get_account
	    auth = Queries.generate_authorization
        @result = Queries.get("bodega/fabrica/getCuenta", 
	    						authorization=auth)
	    return (JSON.parse @result.body)["cuentaId"]
	end


	def self.fabricate(sku, cantidad)
		account_id = Factory.get_account
		origen = Rails.configuration.environment_ids['bank_id']
		unit_cost = Contact.all.where(supplier_id: 2, product_id: sku).first['production_unit_cost']
		monto = unit_cost * cantidad

		local_trx = Bank.transfer(monto, origen, account_id)

		if local_trx.id_cloud != nil
			trx = Bank.get_transaction(local_trx.id_cloud)
			trxId = (JSON.parse trx.body)[0]["_id"]

		    auth = Queries.generate_authorization(_method = 'PUT', 
		                    params = [sku, cantidad, trxId])
		    body = {'sku' => sku , 'cantidad' => cantidad, 'trxId' => trxId}

		    @result = Queries.put('bodega/fabrica/fabricar', 
		              authorization=auth,
		              body=body)
		    return JSON.parse @result.body

		else
			return {"error" => "transacción fallida"}
		end


	end

	def self.hacer_pedido_interno(sku, cantidad)
		## procesado solo acepta de a un lote
		product = Product.find(sku)
		if product.category == "Materia prima"
			result = self.fabricate(sku, cantidad)
			if result.keys.include?("error")
				return false
			else 
      			purchase_order = ProductionOrder.create!(id_cloud: result['_id'], 
                                        				 product_sku: result['sku'],
                                        				 cantidad: result['cantidad'],
                                        				 despachado: result['despachado'],
                                        				 disponible: result['disponible'])
				return true
			end

		elsif product.category == 'Producto procesado'
			needed_products = Recipe.where(final_product_sku: product.sku)

			puts 'evaluando mover a despacho'
			needed_products.each do |recipe|
            	can_sale = Warehouses.product_availability(recipe.needed_product_sku, 
            										recipe.requirement)
				if not can_sale
					return false
				end
			end

			needed_products.each do |recipe|
				eval_despacho = Warehouses.get_despacho_ready(recipe.needed_product_sku,
															  recipe.requirement)
				if not eval_despacho
					return false
				end
			end

			puts 'materia prima disponible para producir producto procesado'
			result = self.fabricate(sku, cantidad)
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