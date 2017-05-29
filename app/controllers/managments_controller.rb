#include HTTParty
class ManagmentsController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc
  include Warehouses
  include RawMaterial
  require 'json'

  def index

  end

  def sent_production
    puts params[:oc_sku]
    puts params[:cantidad]
    req = Factory.hacer_pedido_interno(params[:oc_sku], params[:cantidad].to_i)
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
    comprar = RawMaterial.buy_product_from_supplier(params[:oc_sku], params[:cantidad].to_i, params[:proveedor].to_i,
                          needed_date) #mes, dia, hora, minuto
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
    out = Warehouses.despachar_OC(params[:oc_cloud_id])
    json_response({ret: out})
  end

  def check_for_availablility
    puts "check_for_availablility"
    result = Warehouses.product_availability(params[:oc_sku], params[:cantidad].to_i)
    json_response({ret: result})
  end


  def sort_wh
    ret = Warehouses.sort_warehouses
    json_response({ret: ret})
  end

  def authorize
    redirect_to '/login' unless current_user
  end


end
