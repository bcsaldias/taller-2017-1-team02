
module Sales
	include Queries

	require 'json'

	def self.create_purchase_order(cliente, proveedor, sku, 
									fechaEntrega, cantidad, precioUnitario,
									canal, notas="default-note")

		@body = {'cliente' => cliente, 'proveedor' => proveedor, 'sku' => sku,
				'fechaEntrega' =>fechaEntrega, 'cantidad' => cantidad,
				'precioUnitario' => precioUnitario, 'canal' => canal, 'notas' => notas}

	    @result = Queries.put('oc/crear',
	              				body=@body)
	    
	    order =  JSON.parse @result.body.force_encoding("UTF-8")
        @purchase_order = PurchaseOrder.create!(id_cloud: order['_id'], state: 0,
                                          product_sku: order['sku'],
                                          owner: true)

	    return @purchase_order
	end

	def self.get_purchase_order(purchase_order_id)
		@result = Queries.get(next_path= "oc/obtener/" + purchase_order_id)
		return (JSON.parse @result.body)[0]
	end

	###
	def self.recepcionar_purchase_order(purchase_order_id)
		body = {'id' => purchase_order_id}
		@result = Queries.post(next_path= "oc/recepcionar/" + purchase_order_id, 
						  body=body)
		return @result.body
	end

	###
	def self.rechazar_purchase_order(purchase_order_id, motivo_rechazo)
		body = {'rechazo' => motivo_rechazo}
		@result = Queries.post(next_path= "oc/rechazar/" + purchase_order_id, 
						  body=body)
		return (JSON.parse @result.body)[0]
	end

	###
	def self.anular_purchase_order(purchase_order_id, motivo_anulacion)
		body = {'anulacion' => motivo_anulacion}
		@result = Queries.post(next_path= "oc/anular/" + purchase_order_id, 
						  body=body)
		return @result.body
	end 

	#def self.accept_purchase_order(purchase_order_id)
	#	order = self.get_purchase_order(purchase_order_id)
	#	sup = Supplier.find(2)#.first
	#	ret = Queries.patch_to_groups_api('purchase_orders/'+order['_id']+'/accepted', sup)
	#	return ret
	#end

	def self.accept_purchase_order(purchase_order_id)
		order = self.get_purchase_order(purchase_order_id)
		ret = self.recepcionar_purchase_order(purchase_order_id)
		sup = Supplier.where(id_cloud: order['proveedor']).first
		ret = Queries.patch_to_groups_api('purchase_orders/'+order['_id']+'/accepted', sup)
		return ret
	end

	def self.reject_purchase_order(purchase_order_id, cause)
		order = self.get_purchase_order(purchase_order_id)
		ret = self.rechazar_purchase_order( purchase_order_id=purchase_order_id,
											motivo_rechazo=cause)
		sup = Supplier.where(id_cloud: order['proveedor']).first
		ret = Queries.patch_to_groups_api('purchase_orders/'+order['_id']+'/rejected', sup)
		return ret
	end


end
