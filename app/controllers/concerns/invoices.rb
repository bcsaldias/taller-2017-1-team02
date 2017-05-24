module Invoices
	include Queries
	require 'json'


  def self.emitir_factura(purchase_order_id)
    #PUT/
    #parametro: oc (string)
    #retorno: factura o error

    body = {'oc' => purchase_order_id}
    @result = Queries.put("sii/", authorization=false, body)
    return JSON.parse @result.body

  end

  def self.obtener_factura(invoice_id)
    #GET/:id
    #parametros: id (string)
    #retorno: factura o error

    @result = Queries.get("sii/" + invoice_id)
    return JSON.parse @result.body
  end

  def self.pagar_factura(invoice_id)
    #POST/pay
    #parametros: id(string)
    #retorno: factura o error 

    body = {'id' => invoice_id}
    @result = Queries.post("sii/pay", body = body)
    return JSON.parse @result.body
  end

  def self.rechazar_factura(invoice_id, motive)
    #POST/reject
    #parametros: id(string), motivo
    #retorno: factura o error
    body = {'id' => invoice_id, 'motivo' => motive}
    @result = Queries.post("sii/reject", body = body)
    return JSON.parse @result.body
  end

  def self.anular_factura(invoice_id, motive)
    #POST/cancel
    #parametros: id (string), motivo
    #retorno: factura o error

    body = {'id' => invoice_id, 'motivo' => motive}
    @result = Queries.post("sii/cancel", body = body)
    return JSON.parse @result.body
  end

  def self.crear_boleta(supplier_id, client_id, total)
    #PUT/boleta
    #parametros: proveedor (id?) (grupo que genera la boleta), cliente (string), total (int)
    #retorno: factura o error

    body = {'proveedor' => supplier_id, 'cliente' => client_id, 'total' => total}
    @result = Queries.put("sii/boleta", authorization=false, body)
    return JSON.parse @result.body
  end
end
