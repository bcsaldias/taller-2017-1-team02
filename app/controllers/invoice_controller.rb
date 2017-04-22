class InvoiceController < ApplicationController

  require 'json'


  # PUT /invoices/:id
  def enviar_confirmacion_factura
  end

  # DELETE /invoices/:id
  def enviar_rechazo_factura
  end

  # PATCH /invoices/:id
  def enviar_confirmacion_pago
  end

  # PUT /invoices
  def enviar_factura

      @body =  JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_supplier")
          json_response({ :error => "Proveedor debe ser distinto de nulo" }, 400)

      elsif not @keys.include?("id_invoice")
          json_response({ :error => "Factura debe ser distinto de nulo" }, 400)

      else
      json_response(
          {
            id_supplier: params[:id_supplier],
            id_invoice: params[:id_invoice]
          }, 201)
    end

  end

  # PATCH /invoices/:id
  def notificar_orden_despachada

      json_response(204)

  end


end

