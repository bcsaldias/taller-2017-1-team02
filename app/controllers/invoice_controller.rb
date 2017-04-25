class InvoiceController < ApplicationController

  require 'json'

  # PATCH /invoices/:id
  def enviar_confirmacion_factura
    json_response "", 204
  end

  # PATCH /invoices/:id/rejected
  def enviar_rechazo_factura

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys

      if not @keys.include?("cause")
        json_response ({ error: "Debe entregar una razón de rechazo" }), 404
      elsif params[:cause].length == 0
        json_response ({ error: "La razón debe ser distinta de nula" }), 404
      else
        json_response "", 204
      end

    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  # PATCH /invoices/:id/paid
  def enviar_confirmacion_pago

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_transaction")
        json_response ({ error: "Debe entregar el id de una transacción"}), 400
      else
        json_response "", 204
      end

    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  # PUT /invoices
  def enviar_factura

      begin

        @body =  JSON.parse request.body.read
        @keys = @body.keys
        if not @keys.include?("id_supplier")
            json_response({ :error => "Proveedor debe ser distinto de nulo" }, 400)

        elsif not @keys.include?("id_invoice")
            json_response({ :error => "Factura debe ser distinto de nulo" }, 400)

        elsif not @keys.include?("bank_account")
            json_response({ :error => "Debe proporcionar una cuenta bancaria" }, 400)

        else
        json_response(
            {
              id_supplier: params[:id_supplier],
              id_invoice: params[:id_invoice],
              bank_account: params[:bank_account]
            }, 200)
        end

      rescue
            json_response({ :error => "Formato de Body incorrecto" }, 400)

      end

  end

  # PATCH /invoices/:id
  def notificar_orden_despachada
      json_response('Notificación hecha',204)
  end


end
