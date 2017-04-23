class PurchaseOrderController < ApplicationController

  require 'json'

  # PUT purchase_orders/:id
  def realizar_pedido
    @body = JSON.parse request.body.read
    @keys = @body.keys

    if not @keys.include?("payment_method")
      json_response ({ error: "Falta método de pago"}), 400
    elsif not @keys.include?("id_store_reception")
      json_response ({error: "Falta bodega de recepción"}), 400
    else
      render json: {orden: 15}, status: 201
    end

  end
  # PATCH purchase_orders/:id
  def responder_orden_compra
  end

end
