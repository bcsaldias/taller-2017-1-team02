
module Purchases
	include Queries
  require 'json'

	def self.create_purchase_order(cliente, proveedor, sku,
									fechaEntrega, cantidad, precioUnitario,
									canal, notas="default-note1")

			# @body = {'cliente' => cliente, 'proveedor' => proveedor, 'sku' => sku,
		  @body = {'cliente' => '590baa00d6b4ec0004902463',
				'proveedor' => '590baa00d6b4ec0004902464', 'sku' => sku,
			##fix me: CLIENTE Y PROVEEDOR ESTAN HARCODEADOS, ARREGLAR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				'fechaEntrega' =>fechaEntrega, 'cantidad' => cantidad,
				'precioUnitario' => precioUnitario, 'canal' => canal, 'notas' => "notas"}

			### Creacion OC en sistema
	    @result = Queries.put('oc/crear', body=@body)

			### Creacion OC en base de datos
			order =  JSON.parse @result.body.force_encoding("UTF-8")
      @purchase_order = PurchaseOrder.create!(id_cloud: order['_id'], state: 0,
                                        product_sku: order['sku'],
                                        owner: true)
			### Mensaje de creacion de purchase order a Proveedor
			#fix me
			params = {
				payment_method: "contra_factura",
			  id_store_reception: get_warehouses_id(:recepcion) #METODO COKE
			}
			result = Queries.put_to_groups_api("realizar_pedido", supplier, false, params)
	    return result.code #Status code de el mensaje enviado al proveedor
	end

end
