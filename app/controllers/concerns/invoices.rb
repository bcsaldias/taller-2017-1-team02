module Invoices
	include Queries
  require 'json'

	def self.crear_boleta(order_id, private_client_id, amount, _address)

    origin_group_id = Rails.configuration.environment_ids['team_id']
  	body = {'proveedor' => origin_group_id,
  			'cliente' => private_client_id,
  			'total' => amount}

		@result = Queries.put("sii/boleta", authorization=false, body)
		@body = JSON.parse @result.body

		if @result.code == 200 or @result.code == 201
			Voucher.create!(id_cloud: @body['_id'],
              spree_order_id: order_id,
							client: @body['cliente'],
							bruto: @body['bruto'].to_i,
							iva: @body['iva'].to_i,
							oc_id_cloud: @body['oc'],
							status: @body['estado'],
              address: _address
				)
		end

		return @body#.code
	end

  def self.emitir_factura(purchase_order_id)
    #descripcion: emitir factura a partir de una orden de compra (PROVEEDOR)
    #PUT/
    #parametro: oc (string)
    #retorno: factura o error
    #testeada
    body = {'oc' => purchase_order_id}
    @result = Queries.put("sii/", authorization=false, body)
    return JSON.parse @result.body

  end

  def self.obtener_factura(invoice_id)
    #descripcion: permite a un proveedor obtener una factura (PROVEEDOR)
    #GET/:id
    #parametros: id (string)
    #retorno: factura o error
    #testeada
    @result = Queries.get("sii/" + invoice_id)
    return JSON.parse @result.body
  end

  def self.pagar_factura(invoice_id)
		invoice = self.obtener_factura(invoice_id)
		our_invoice = Invoice.where(id_cloud: invoice_id).first
		our_invoice.state = 1
		our_invoice.save!
		ret = self.recepcionar_purchase_order(purchase_order_id)
		sup = Supplier.get_by_id_cloud(invoice['cliente'])
		ret = Queries.patch_to_groups_api('invoices/'+invoice['_id']+'/paid', sup)
    return ret
  end

  def self.rechazar_factura(invoice_id, motive)
    #POST/reject
    #parametros: id(string), motivo
    #retorno: factura o error
    #testeada
    body = {'id' => invoice_id, 'motivo' => motive}
    @result = Queries.post("sii/reject", body = body)
    return JSON.parse @result.body
  end

  def self.anular_factura(invoice_id, motive)
    #POST/cancel
    #parametros: id (string), motivo
    #retorno: factura o error
    #testeada
    body = {'id' => invoice_id, 'motivo' => motive}
    @result = Queries.post("sii/cancel", body = body)
    return JSON.parse @result.body
  end

end
