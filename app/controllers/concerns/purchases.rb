
module Purchases
	include Queries
  require 'json'

	#Fix me, este codigo lo deberia pasar a self.create_purchase_order
  def self.realizar_pedido(supplier, metodo_pago, id_oc)
		#Coke lo implemento pero aun no lo sube al repositorio
		id_bodega = get_warehouses_id(:recepcion)

		params = {
			payment_method: metodo_pago,
		  id_store_reception: id_bodega
		}
		result = Queries.put_to_groups_api("realizar_pedido", supplier, false, params)
		return result.code
	end
end
