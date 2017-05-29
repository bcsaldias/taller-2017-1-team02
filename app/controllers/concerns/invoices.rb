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
    @body = JSON.parse @result.body
    if @result.code == 200 or @result.code == 201
      Invoice.create!(id_cloud: @body['_id'],
              proveedor: @body['proveedor'],
              client: @body['cliente'],
              bruto: @body['bruto'].to_i,
              iva: @body['iva'].to_i,
              oc_id_cloud: @body['oc'],
              status: @body['estado'],
              created_at: @body['created_at'],
              updated_at: @body['updated_at']
        )
    return @body
    

  end

  def self.obtener_factura(invoice_id)
    #descripcion: permite a un proveedor obtener una factura (PROVEEDOR) 
    #GET/:id
    #parametros: id (string)
    #retorno: factura o error
    #testeada
    @result = Queries.get("sii/" + invoice_id)
    return (JSON.parse @result.body)[0]
  end

  def self.pagar_factura(invoice_id)
    #descripcion: permite a un proveedor marcar una factura como pagada (PROVEEDOR)
    #POST/pay
    #parametros: id(string)
    #retorno: factura o error 
    #testeada
    body = {'id' => invoice_id}
    @result = Queries.post("sii/pay", body = body)
    return JSON.parse @result.body
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

  #eviar a otros grupos

  #PATCH /invoices/:id/accepted
  def self.enviar_confirmacion_factura(invoice_id)
    #enum status: [:pendiente, :pagada, :anulada, :rechazada, :aceptada]
    invoice = self.obtener_factura(invoice_id)
    our_invoice = Invoice.where(id_cloud: invoice_id).first
    our_invoice.status = 4
    our_invoice.save!
    sup = Supplier.get_by_id_cloud(invoice['proveedor'])
    ret = Queries.patch_to_groups_api('invoices/'+invoice['_id']+'/accepted', sup)
    return ret
  end

   # PATCH /invoices/:id/rejected
  def self.enviar_rechazo_factura(invoice_id, cause)
    invoice = self.obtener_factura(invoice_id)
    our_invoice = Invoice.where(id_cloud: invoice_id).first
    our_invoice.status = 3
    our_invoice.save!
    ret = self.rechazar_factura( invoice_id=invoice_id,
                      motive=cause)
    sup = Supplier.get_by_id_cloud(invoice['proveedor'])
    ret = Queries.patch_to_groups_api('invoices/'+invoice['_id']+'/rejected', sup)
    return ret
  end

  #PUT /invoices/:id
  def enviar_factura(invoice_id, bank_account)
    invoice = self.obtener_factura(invoice_id)
    sup = Supplier.get_by_id_cloud(invoice['cliente'])
    our_account = Rails.configuration.environment_ids['bank_id']

    @body = { 'bank_account' => our_account }
    ret = Queries.put_to_groups_api('invoices/'+invoice['_id'], 
                                    access_token=false, params={}, body=@body)
    return ret
  end


  def self.notificar_orden_despachada(invoice_id)
    invoice = self.obtener_factura(invoice_id)

    sup = Supplier.get_by_id_cloud(invoice['cliente']) 
    ret = Queries.patch_to_groups_api('invoices/'+invoice['_id']+'/delivered', sup)

    invoice = Invoice.where(id_cloud: invoice_id).first
    invoice.status = 5
    invoice.save!

    oc_id = invoice['oc']
    purchase_order = PurchaseOrder.all.where(id_cloud: oc_id)
    purchase_order.state = 3
    purchase_order.save!
    # poner finalizada a la OC del profe, asumimos que el profe lo cambia.

    return ret

  end

end
