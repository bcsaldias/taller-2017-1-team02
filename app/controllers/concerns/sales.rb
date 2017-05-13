
module Sales
	include Queries
	require 'json'

	def self.create_purchase_order(cliente, proveedor, sku, 
									fechaEntrega, cantidad, precioUnitario, 
									canal, notas)

		@body = {'cliente' => cliente, 'proveedor' => proveedor, 'sku' => sku, 
				'fechaEntrega' =>fechaEntrega, 'cantidad' => cantidad, 
				'precioUnitario' => precioUnitario, 'canal' => canal, 'notas' => notas}
		
	    @result = Queries.put('oc/crear',
	              				body=@body)
	    return @result.body.force_encoding("UTF-8")
	end

	def self.get_purchase_order(purchase_order_id)
		@result = Queries.get(next_path= "oc/obtener/" + purchase_order_id)
		return (JSON.parse @result.body)[0]
	end

	def self.anular_purchase_order(purchase_order_id, anulacion)
		body = {'id' => purchase_order_id, 'anulacion' => anulacion}
		@result = Queries.post(next_path= "oc/anular/" + purchase_order_id, 
						  body=body)
		return @result.body
	end 

	def self.recepcionar_purchase_order(purchase_order_id)
		body = {'id' => purchase_order_id}
		@result = Queries.post(next_path= "oc/recepcionar/" + purchase_order_id, 
						  body=body)
		return @result.body
	end

	def self.rechazar_purchase_order(purchase_order_id, rechazo)
		body = {'id' => purchase_order_id, 'rechazo' => rechazo}
		@result = Queries.post(next_path= "oc/rechazar/" + purchase_order_id, 
						  body=body)
		return @result.body
	end

end