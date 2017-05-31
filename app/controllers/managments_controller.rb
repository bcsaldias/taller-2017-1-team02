#include HTTParty
class ManagmentsController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc
  include Warehouses
  include RawMaterial
  require 'json'

  def index
    @being_delivered = PurchaseOrder.where(delivering: true)
  end

  def prices_force_update
    req = Product.force_update
    json_response({req: req})
  end

  def sent_production
    puts params[:oc_sku]
    puts params[:cantidad_raw_material]
    req = Factory.hacer_pedido_interno(params[:oc_sku],
                      params[:cantidad_raw_material].to_i)
    json_response({req: req})
  end

  def accept_oc
    @end =  nil
    if params[:status] == "Aceptar"
      @end = Sales.accept_purchase_order(params[:cloud_id])
    elsif params[:status] == "Rechazar"
      @end = Sales.reject_purchase_order(params[:cloud_id], cause='no alcanzamos')
    end
    json_response({oc:params[:cloud_id], status:params[:status]})
  end

  def create_oc
    mes = params[:fecha_mes]
    dia = params[:fecha_dia]
    hora = params[:fecha_hora]
    minutos = params[:fecha_minutos]
    needed_date =  Tiempo.tiempo_a_milisegundos(mes, dia, hora, minutos)
    comprar = RawMaterial.buy_product_from_supplier(params[:oc_sku], params[:cantidad].to_i,
                          params[:proveedor].to_i, needed_date) #mes, dia, hora, minuto
  	json_response({ret: comprar})
  end

  def create_oc_with_price
    mes = params[:fecha_mes]
    dia = params[:fecha_dia]
    hora = params[:fecha_hora]
    minutos = 0
    precio_unitario = params[:unit_price].to_i
    sku = params[:oc_sku]
    prov = params[:proveedor]
    cant = params[:cantidad]
    needed_date =  Tiempo.tiempo_a_milisegundos(mes, dia, hora, minutos)
    our_id = Rails.configuration.environment_ids['team_id']
    supplier = Supplier.find(prov)
    puts "Entre al create_oc_with_price"
    comprar = Purchases.create_purchase_order(our_id, supplier, sku,
                    needed_date, cant.to_i, precio_unitario,
                    "b2b", notas="default-note1")

  	json_response({ret: comprar})
  end

  def notify_deliver
    puts "notify_deliver"
    puts params[:oc_cloud_id]
    puts params[:factura_cloud_id]
    puts params[:proveedor]
    redirect_to :managment
    ## FIXMEE
    ## esto va contra factura!
  end

  def deliver
    puts "deliver"
    puts params[:oc_cloud_id]
    puts params[:factura_cloud_id]
    puts params[:proveedor]
    order = PurchaseOrder.where(id_cloud: params[:oc_cloud_id]).first
    order.delivering = true
    order.save!
    out = Warehouses.despachar_OC(params[:oc_cloud_id])
    json_response({ret: out})
  end

  def check_for_availablility
    puts "check_for_availablility"
    #result = Warehouses.product_availability(params[:oc_sku], params[:cantidad].to_i)
    cantidad = params[:cantidad].to_i
    product = Product.find(params[:oc_sku])
    json_response({ret: product.stock_disponible >= cantidad})
  end


  def sort_wh
    ret = Warehouses.sort_warehouses
    json_response({ret: ret})
  end

# Obtiene todas las transacciones del servidor y almacena localmente
  def refresh_transactions
    puts "Entro al metodo"

    #fechaInicio = (Time.now - 1.week).to_f*1000 # 1 semana atras
    fechaInicio = 1 # Desde 1970
    transactions_query = Bank.get_our_card(9999999999, fechaInicio)
    puts transactions_query
    transactions =  transactions_query['data']
    counter = 0
    cant = 0
    transactions.where(owner: nil).each do |trx|
      temp_trx = Transaction.where(id_cloud: trx['_id']).first
      cant += 1

      puts "#{trx['_id']}: #{temp_trx}"
      if temp_trx == nil
        owner = (trx['origen'] == Rails.configuration.environment_ids['bank_id'])
        counter += 1
        Transaction.create!(id_cloud: trx['_id'],
                            origen: trx['origen'],
                            destino: trx['destino'],
                            monto: trx['monto'],
                            owner: owner,
                            state: true)
      end
    end

    json_response({ret: "Actualizado!", cant: cant, trx_descargadas: counter})
  end

  # Revisa que todas las PO locales esten actualizadas con servidor
  def refresh_purchase_orders
    cant =  PurchaseOrder.all.count
    refreshed = false
    PurchaseOrder.all.each do |po|
      id_cloud = po.id_cloud
      cloud_po = Sales.get_purchase_order(id_cloud)
      puts "Local: #{po.state} - Nube: #{cloud_po["estado"]}"
      if po.state != cloud_po["estado"]
        po.state = cloud_po["estado"]
        po.save!
        refreshed = true
        puts "Modifico State: #{po.state}"
      end
      puts "Q local: #{po.quantity_done} -- Q nube: #{cloud_po["cantidadDespachada"]}"

      if po.quantity_done != cloud_po["cantidadDespachada"]
        po.quantity_done = cloud_po["cantidadDespachada"]
        po.save!
        refreshed = true
      end

    end
    json_response({resp: "Todo estaba OK", cantidad_oc: cant }) and return if !refreshed
    json_response({response: "Actualizado"})
  end







  def authorize
    redirect_to '/login' unless current_user
  end


end
