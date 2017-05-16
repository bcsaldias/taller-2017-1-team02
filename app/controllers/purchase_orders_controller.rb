class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :update, :destroy]

  require 'json'

  api! "realizar_pedido: Crea una notificación de que se nos hizo una orden de compra.
      Debe tener el id de la orden de compra, el método de pago (puede ser
      contra factura o contra despacho) y el id de la bodega."
  param :payment_method, String, :required => true, :desc => "Método de pago contra_factura o contra_despacho."
  param :id_store_reception, String, :required => true, :desc => "Identificador de la bodega en que se recibirán los productos."
  error 400, "Formato de  Body incorrecto"
  error 400, "Falta método de pago"
  error 400, "Error de proveedor"
  error 400, "Falta bodega de recepción"
  error 404, "Orden de compra inexistente"
  error 500, "El envío ha fallado"
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
        if ['contra_factura', 'contra_despacho'].include?(params[:payment_method])
          order = Sales.get_purchase_order(params[:id])
          @purchase_order = PurchaseOrder.create!(id_cloud: order['_id'], state: 0,
                                              product_sku: order['sku'],
                                              payment_method: params[:payment_method],
                                              id_store_reception:  params[:id_store_reception])

          begin
            return json_response(@purchase_order, 201)
          rescue
            puts "error"
          ensure
            puts "evaluando solicitud recibida", params[:id]
            ##
            ## if plazo menor a 2 horas:
            ##
            ##
            deadline_in = 900000000000000
            if deadline_in < 1000*60*60*1 #1 horas
              we_can = Warehouses.product_availability(order['sku'], order['cantidad'])
              if we_can
                puts 'oc aceptada'
                Sales.accept_purchase_order(params[:id])
                puts 'despachando oc'
                Warehouses.despachar_oc(params[:id])
                Sales.deliver_purchase_order(params[:id])
              else
                puts 'oc rechazada'
                Sales.reject_purchase_order(params[:id], "no tenemos stock para cumplir plazo")
              end
            end
          end
        else
          json_response ({error: "payment_method: contra_factura/contra_despacho"}), 400
        end
      end
    rescue
      json_response({ :error => "No se pudo crear" }, 400)
    end

  end

  api! "confirmar_orden_compra: Crea una notificación de aceptación de la orden de compra generada por nosotros.
      Debe tener el id de la orden de compra."
    error 403, "Ya se confirmó/rechazó entrega de esta orden de compra"
    error 404, "Orden de compra no existe"
    error 404, "Orden de compra no encontrada para ese proveedor"

  # PATCH purchase_orders/:id/accepted
  def confirmar_orden_compra
      oc = PurchaseOrder.where(id_cloud: params[:id]).first
      begin
        if oc
          if oc.state == "aceptada" or oc.state == "rechazada"
            json_response ({ error: "Ya se confirmó/rechazó entrega de esta orden de compra" }), 403
          elsif oc.state == "finalizada"
            json_response ({ error: "Ya se finalizó esta orden de compra" }), 403
          else
            oc.state = 1
            oc.save
            json_response(
                {
                  id_purchase_order: params[:id],
                  state: oc.state
                }, 200)
          end
        else
            json_response(
                { error: 'oc no encontrada'
                }, 404)
        end
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end

  api! "rechazar_orden_compra: Crea una notificación de rechazo de la orden de compra generada por nosotros.
      Debe tener el id de la orden de compra."

  param :cause, String, :required => true, :desc => "Causa de rechazo."
  error 400, "Formato de  Body incorrecto"
  error 400, "Debe entregar una razón de rechazo"
  error 400, "Razón debe ser distinta de nula"
  error 403, "Ya se confirmó/rechazó entrega de esta orden de compra"
  error 404, "Orden de compra no existe"
  error 404, "Orden de compra no encontrada para ese proveedor"

  # PATCH purchase_orders/:id/rejected
  def rechazar_orden_compra
      oc = PurchaseOrder.where(id_cloud: params[:id]).first
      begin
        @body =  JSON.parse request.body.read
        @keys = @body.keys

        if not @keys.include?("cause")
          json_response ({ error: "Debe entregar una razón de rechazo" }), 400
        elsif params[:cause].length == 0
          json_response ({ error: "La razón debe ser distinta de nula" }), 400
        elsif oc.state == "aceptada" or oc.state == "rechazada"
          json_response ({ error: "Ya se confirmó/rechazó entrega de esta orden de compra" }), 403
        elsif oc.state == "finalizada"
          json_response ({ error: "Ya se finalizó esta orden de compra" }), 403
        else
          oc.state = 2
          oc.cause = params[:cause]
          oc.save

          begin
            return json_response(
                {
                  id_purchase_order: params[:id],
                  state: oc.state
                }, 200)
          rescue
            print "error rechazar_orden_compra"
          ensure
            rejected_order = Sales.get_purchase_order(params[:id])
            new_production_order =  RawMaterial.restore_stock(rejected_order[:sku], rejected_order[:cantidad])
            puts "mandar a producir por rechazo"
          end

        end
      rescue
        json_response({ :error => "Formato de Body incorrecto" }, 400)
      end
  end

  # GET /purchase_orders
  def index
    @purchase_orders = PurchaseOrder.all

    render json: @purchase_orders
  end

  # GET /purchase_orders/1
  def show
    render json: @purchase_order
  end

  # POST /purchase_orders
  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)

    if @purchase_order.save
      render json: @purchase_order, status: :created, location: @purchase_order
    else
      render json: @purchase_order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /purchase_orders/1
  def update
    if @purchase_order.update(purchase_order_params)
      render json: @purchase_order
    else
      render json: @purchase_order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /purchase_orders/1
  def destroy
    @purchase_order.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def purchase_order_params
      params.permit(:id_cloud, :state, :product_sku, :payment_method, :id_store_reception) #.require(:purchase_order)
    end
end
