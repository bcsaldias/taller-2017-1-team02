
module Purchases
	include Queries
  require 'json'

	def self.create_purchase_order(cliente, proveedor, sku,
									fechaEntrega, cantidad, precioUnitario,
									canal, notas="default-note1")

			@body = {'cliente' => cliente, 'proveedor' => proveedor.id_cloud, 'sku' => sku,
				'fechaEntrega' =>fechaEntrega, 'cantidad' => cantidad,
				'precioUnitario' => precioUnitario, 'canal' => canal, 'notas' => "notas"}

			### Creacion OC en sistema
	    	@result = Queries.put('oc/crear', authorization=false, body=@body, params={})

			### Creacion OC en base de datos
			order =  JSON.parse @result.body.force_encoding("UTF-8")
			puts order
      		@purchase_order = PurchaseOrder.create!(id_cloud: order['_id'], state: 0,
                                        product_sku: order['sku'], payment_method: "contra_factura",
										quantity: cantidad, owner: true)


			### Mensaje de creacion de purchase order a Proveedor
			#fix me (No testeado pq nadie tiene la pagina levantada)
			params = {
			  payment_method: "contra_factura",
			  id_store_reception: Rails.configuration.environment_ids['reception_id'] #METODO COKE
			}


			result = Queries.put_to_groups_api("purchase_orders/"+order['_id'], proveedor, false, params)
	    return result.code #Status code de el mensaje enviado al proveedor
	end

end
