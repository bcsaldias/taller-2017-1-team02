
module Purchases
	include Queries
  require 'json'

	def self.create_purchase_order(cliente, proveedor, sku,
									fechaEntrega, cantidad, precioUnitario,
									canal, notas="default-note1")


			@body = {'cliente' => cliente, 'proveedor' => proveedor.id_cloud, 'sku' => sku,
				'fechaEntrega' =>fechaEntrega, 'cantidad' => cantidad,
				'precioUnitario' => precioUnitario.to_i, 'canal' => canal, 'notas' => "notas"}

			### Creacion OC en sistema
	    	@result = Queries.put('oc/crear', authorization=false, body=@body, params={})
				puts "Creo OC en sist profe, code: #{@result.code}"

			puts @result
			### Creacion OC en base de datos
			order =  JSON.parse @result.body.force_encoding("UTF-8")
			puts order
      		@purchase_order = PurchaseOrder.create!(id_cloud: order['_id'],
															state: 0,
                                        					product_sku: order['sku'],
															payment_method: "contra_factura",
															quantity: cantidad,
															quantity_done: 0,
															owner: true,
															deadline: order['fechaEntrega'],
															group_number: proveedor.id,
															team_id_cloud: proveedor.id_cloud
															)
			puts "Creo OC local"

			### Mensaje de creacion de purchase order a Proveedor
			params = {
			  payment_method: "contra_factura",
			  id_store_reception: Rails.configuration.environment_ids['reception_id'] #METODO COKE
			}


			result = Queries.put_to_groups_api("purchase_orders/"+order['_id'], proveedor, false, params)
			puts "Aviso de OC al grupo, code: #{result.code}"
			puts result
			#puts JSON.parse result.body.force_encoding("UTF-8")
	    return result.code #Status code de el mensaje enviado al proveedor
	end

end
