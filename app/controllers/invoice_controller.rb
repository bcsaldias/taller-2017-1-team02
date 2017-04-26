class InvoiceController < ApplicationController

  require 'json'

  api! "Crea una notificación de que no se rechazará la factura enviada.
      Debe tener el id de la factura"
  # PATCH /invoices/:id/accepted
  def enviar_confirmacion_factura
    json_response "", 204
  end

  api! "Crea una notificación de que se rechaza la factura enviada.
      Debe tener el id de la factura."
  param :cause, String, :required => true
  # PATCH /invoices/:id/rejected
  def enviar_rechazo_factura

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys

      if not @keys.include?("cause")
        json_response ({ error: "Debe entregar una razón de rechazo" }), 400
      elsif params[:cause].length == 0
        json_response ({ error: "La razón debe ser distinta de nula" }), 400
      else
        json_response "", 204
      end

    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  api! "Crea una notificación de que se pagó la factura.
      Debe tener el id de la factura."
  param :id_transaction, String, :required => true
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

  api! "Crea una notificación de habernos emitido una factura.
      Debe tener el id de la factura y la cuenta del banco."
  param :bank_account, String, :required => true
  # PUT /invoices/:id
  def enviar_factura

      begin

        @body =  JSON.parse request.body.read
        @keys = @body.keys

        if not @keys.include?("bank_account")
            json_response({ :error => "Debe proporcionar una cuenta bancaria" }, 400)

        else
            json_response(
            {
              id_invoice: params[:id],
              bank_account: params[:bank_account]
            }, 200)
        end

      rescue
            json_response({ :error => "Formato de Body incorrecto" }, 400)

      end

  end

  api! "Notificar para cambiar de estado de una factura.
      Debe tener el id de la factura."
  # PATCH /invoices/:id
  def notificar_orden_despachada
      json_response('Notificación hecha',204)
  end


end
