
module Sales
	include Queries

	require 'json'

	def self.get_purchase_order(purchase_order_id)
		@result = Queries.get(next_path= "oc/obtener/" + purchase_order_id)
		return (JSON.parse @result.body)[0]
	end

	def self.recepcionar_purchase_order(purchase_order_id)
		body = {'id' => purchase_order_id}
		@result = Queries.post(next_path= "oc/recepcionar/" + purchase_order_id,
						  body=body)
		return @result.body
	end

	def self.rechazar_purchase_order(purchase_order_id, motivo_rechazo)
		body = {'rechazo' => motivo_rechazo}
		@result = Queries.post(next_path= "oc/rechazar/" + purchase_order_id,
						  body=body)
		return (JSON.parse @result.body)
	end

	def self.anular_purchase_order(purchase_order_id, motivo_anulacion)
		body = {'anulacion' => motivo_anulacion}
		@result = Queries.post(next_path= "oc/anular/" + purchase_order_id,
						  body=body)
		return @result.body
	end

	def self.accept_ftp_order(purchase_order_id)
		order = self.get_purchase_order(purchase_order_id)
		our_order = PurchaseOrder.where(id_cloud: purchase_order_id).first
		our_order.state = 1
		our_order.queued = true
		our_order.save!
		ret = self.recepcionar_purchase_order(purchase_order_id)
		return ret
	end

	def self.reject_ftp_order(purchase_order_id, cause)
		order = self.get_purchase_order(purchase_order_id)
		our_order = PurchaseOrder.where(id_cloud: purchase_order_id).first
		our_order.state = 2
		our_order.queued = false
		our_order.save!
		ret = self.rechazar_purchase_order( purchase_order_id=purchase_order_id,
											motivo_rechazo=cause)
		return ret
	end

	def self.accept_purchase_order(purchase_order_id)
		order = self.get_purchase_order(purchase_order_id)
		our_order = PurchaseOrder.where(id_cloud: purchase_order_id).first
		our_order.state = 1
		#our_order.queued = true
		our_order.save!
		ret = self.recepcionar_purchase_order(purchase_order_id)
		sup = Supplier.get_by_id_cloud(order['cliente'])
		return_factura = Invoices.emitir_factura(purchase_order_id)
		puts "Imprimo factura: #{return_factura}"
		ret = Queries.patch_to_groups_api('purchase_orders/'+order['_id']+'/accepted', sup)
		ret = Invoices.enviar_factura(return_factura['_id'])
		return ret
	end

	def self.reject_purchase_order(purchase_order_id, cause)
		order = self.get_purchase_order(purchase_order_id)
		our_order = PurchaseOrder.where(id_cloud: purchase_order_id).first
		our_order.state = 2
		our_order.queued = false
		our_order.save!
		ret = self.rechazar_purchase_order( purchase_order_id=purchase_order_id,
											motivo_rechazo=cause)
		sup = Supplier.get_by_id_cloud(order['cliente']) #Supplier.where(id_cloud: order['proveedor']).first
		ret = Queries.patch_to_groups_api('purchase_orders/'+order['_id']+'/rejected', sup)
		return ret
	end


end
