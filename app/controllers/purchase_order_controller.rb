class PurchaseOrderController < ApplicationController

  require 'json'

  api! "Crea una notificación de que se nos hizo una orden de compra.
      Debe tener el id de la orden de compra, el método de pago (puede ser
      contra factura o contra despacho) y el id de la bodega"
  param :payment_method, String, :required => true
  param :id_store_reception, String, :required => true
  # PUT purchase_orders/:id
  def realizar_pedido

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("payment_method")
        json_response ({ error: "Falta método de pago"}), 400

      elsif not @keys.include?("id_store_reception")
        json_response ({error: "Falta bodega de recepción"}), 400

      else
        render json: {orden: 15}, status: 201
      end
    rescue
      json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  api! "Crea una notificación de aceptación de la orden de compra generada por nosotros.
      Debe tener el id de la orden de compra."
  param :id_supplier, String
  # PATCH purchase_orders/:id/accepted
  def confirmar_orden_compra

      begin
  	    json_response(
  					{
  					  id_purchase_order: params[:id],
  					  accepted: true
  					}, 200)
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end

  api! "Crea una notificación de rechazo de la orden de compra generada por nosotros.
      Debe tener el id de la orden de compra y la respuesta (Boolean)."

  param :id_supplier, String
  param :cause, String, :required => true
  # PATCH purchase_orders/:id/rejected
  def rechazar_orden_compra

      begin
        @body =  JSON.parse request.body.read
        @keys = @body.keys

        if not @keys.include?("cause")
          json_response ({ error: "Debe entregar una razón de rechazo" }), 400
        elsif params[:cause].length == 0
          json_response ({ error: "La razón debe ser distinta de nula" }), 400
        else
        json_response(
            {
              id_purchase_order: params[:id],
              accepted: false
            }, 200)
        end
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end

end
