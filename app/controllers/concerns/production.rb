##puts
module Production
	include Queries
  	require 'json'

	def self.get_warehouses
		auth = Queries.generate_authorization
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
		return JSON.parse @result.body.force_encoding("UTF-8")
	end

	def self.get_all_stock_warehouse(warehouse_id)
		auth = Queries.generate_authorization(_method = 'GET',
												params = [warehouse_id])
		@result = Queries.get("bodega/skusWithStock",
						  authorization=auth,
						  params = {almacenId: warehouse_id})
		return JSON.parse @result.body
	end

	def self.move_stock(warehouse_id, product_id)

		auth = Queries.generate_authorization(_method = 'POST',
											  params = [product_id, warehouse_id])

		body = {"productoId" => product_id , "almacenId" => warehouse_id}
		@result = Queries.post("bodega/moveStock",
							body=body, params={},
							authorization=auth)
		return JSON.parse @result.body.force_encoding("UTF-8")
	end

	def self.move_stock_external(warehouse_id, product_id, purchase_order, price)
		auth = Queries.generate_authorization(_method = 'POST',
											  params = [product_id, warehouse_id])

		body = {"productoId" => product_id,
				"almacenId" => warehouse_id,
			    "oc" => purchase_order,
				"precio" => price.to_i}

		@result = Queries.post("bodega/moveStockBodega",
							body=body, 
							params={},
							authorization=auth)
		return @result#JSON.parse   .body.force_encoding("UTF-8")
	end

	def self.deliver_product(boleta, productoId)

		@direccion = boleta.address
	    puts "LLEGO 0"
	    puts "LLEGO 0"

		@precio = boleta.iva + boleta.bruto
		@oc = boleta.oc_id_cloud

	    @auth = Queries.generate_authorization(_method = 'DELETE', 
	                    params = [productoId, @direccion, @precio, @oc])

	    puts "LLEGO 1"
	    puts "LLEGO 1"

	    @body = {   'productoId' => productoId, 
	    			'direccion' => @direccion,
	    			'precio' => @precio, 
	    			'oc' => @oc }
		
		ret = Queries.delete('bodega/stock', @auth, @body)
		puts ret

		if ret.code == 200 or ret.code == 201
			return true
		end
		return false

	end

	def self.save_order_for_delivering(boleta)

		@order = Spree::Order.find_by_number(boleta.spree_order_id)
        @order.shipments.each do |_o|
          _o.manifest.each do |_m|

			    @voucher_stocks = VoucherStock.where(voucher_id: boleta.id).entries
			    voucher_params = {
					      sku: _m.variant.sku.to_s,
					      quantity: _m.quantity.to_i,
					      quantity_done: 0
			    		}
			    @voucher_stock = boleta.voucher_stocks.build(voucher_params)
			    @voucher_stock.save!
          end
        end

	end

	def self.deliver_order_to_address(boleta_id)
		## FIXME poner como despachado

		boleta = Voucher.find(boleta_id.to_i)
    	warehouses_id = Warehouses.get_warehouses_id
		@order = Spree::Order.find_by_number(boleta.spree_order_id)

		#self.save_order_for_delivering(boleta, @order)

        @order.shipments.each do |_o|
          _o.manifest.each do |_m|

          	_sku = _m.variant.sku.to_s
	        v_stock = VoucherStock.where(voucher_id: boleta.id, sku: _sku).first

          	_quant = v_stock.quantity.to_i - v_stock.quantity_done.to_i #_m.quantity.to_i

          	ret = Warehouses.get_despacho_ready(_sku, _quant)
            if not ret
            	return ret #FIXME
            end

    		stock_a_despachar = self.get_stock(warehouses_id['despacho'], _sku.to_s)


            count = 0
    		while count < _quant
    			product  = stock_a_despachar[count]
	            ret = self.deliver_product(boleta, product['_id'])

	            if not ret
		            return ret #FIXME
	            else
	            	v_stock.quantity_done = v_stock.quantity_done + 1
	            	v_stock.save!
	            	count += 1
	            end
	        end

		  end
		end

        boleta.status = 'despachada'
        boleta.save!

		return true
	end

	def self.delete_ftp_stock(direccion, product_id, purchase_order_id, price)
	    @auth = Queries.generate_authorization(_method = 'DELETE', 
	                    params = [product_id, direccion, price, purchase_order_id])
	    @body = {   'productoId' => product_id, 
	    			'direccion' => direccion,
	    			'precio' => price, 
	    			'oc' => purchase_order_id }
		ret = Queries.delete('bodega/stock', @auth, @body)
		return ret
	end

	def self.deliver_ftp_order(order_id)
		query = Invoice.where(oc_id_cloud: order_id)

		can_deliver = false
		if query.count == 0
			Invoices.emitir_factura(order_id)
		elsif query.count == 1
			can_deliver = true
		end
			
		if not can_deliver
			query = Invoice.where(oc_id_cloud: order_id)
			if query.count == 1
				can_deliver = true
			end
		end

		if can_deliver
			# Agregar a la cola!
			#Warehouses.despachar_OC(order_id, distribuidor=true)
		end

	end

end
