class PurchaseOrderController < ApplicationController


  require 'json'



  # PUT purchase_orders/:id
  def realizar_pedido
  end

  # PATCH purchase_orders/:id/accepted
  def confirmar_orden_compra

      begin
        @body =  JSON.parse request.body.read
        @keys = @body.keys
        if not @keys.include?("id_supplier")
            json_response({ :error => "Proveedor debe ser distinto de nulo" }, 400)

        else
  	    json_response(
  					{
  					  id_supplier: params[:id_supplier],
  					  id_purchase_order: params[:id],
  					  accepted: true
  					}, 200)
  	    end
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end
  
  # PATCH purchase_orders/:id/rejected
  def rechazar_orden_compra

      begin
        @body =  JSON.parse request.body.read
        @keys = @body.keys
        if not @keys.include?("id_supplier")
            json_response({ :error => "Proveedor debe ser distinto de nulo" }, 400)
        else
        json_response(
            {
              id_supplier: params[:id_supplier],
              id_purchase_order: params[:id],
              accepted: false
            }, 200)
        end
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end

end
