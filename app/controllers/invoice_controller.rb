class InvoiceController < ApplicationController

  # PATCH /invoices/:id/accepted
  def enviar_confirmacion_factura
    json_response "", 204
  end

  # DELETE /invoices/:id/rejected
  def enviar_rechazo_factura
    json_response "", 204
  end

  # PATCH /invoices/:id/paid
  def enviar_confirmacion_pago
    @body = JSON.parse request.body.read
    @keys = @body.keys

    if not @keys.include?("id_payment")
      json_response ({ error: "Pago no existente"}), 404
    else
      json_response "", 204
    end
  end

  # PUT /invoices
  def enviar_factura
  end

  # PATCH /invoices/:id
  def notificar_orden_despachada
  end
end
