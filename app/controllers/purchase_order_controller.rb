class PurchaseOrderController < ApplicationController


  require 'json'



  # PUT purchase_orders/:id
  def realizar_pedido
  end

  # PATCH purchase_orders/:id
  def responder_orden_compra

      @body =  JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_provider")
          json_response({ :error => "Proveedor debe ser distinto de nulo" }, 400)

      elsif not @keys.include?("accepted")
          json_response({ :error => "Debe proporcionar boolean de aceptación" }, 400)

      else
	    json_response(
					{
					  id_provider: params[:id_provider],
					  id_purchase_order: params[:id],
					  accepted: params[:accepted]
					}, 200)
	  end
  end
  
end
