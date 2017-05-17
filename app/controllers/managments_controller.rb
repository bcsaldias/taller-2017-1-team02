#include HTTParty
class ManagmentsController < ApplicationController
  before_filter :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc
  include Warehouses
  include RawMaterial
  require 'json'

  def index

  end

  def sent_production
  	puts params[:oc_sku]
  	puts params[:cantidad]
    Factory.hacer_pedido_interno(params[:oc_sku], params[:cantidad].to_i)
  	redirect_to :managment
  end

  def accept_oc
    @end =  nil
    if params[:status] == "Aceptar"
      @end = Sales.accept_purchase_order(params[:cloud_id])
    elsif params[:status] == "Rechazar"
      @end = Sales.reject_purchase_order(params[:cloud_id], cause: 'no alcanzamos')
    end
    json_response({oc:params[:cloud_id], status:params[:status]})
    #redirect_to :managment
  end

  def reject_oc
    puts params[:id_cloud]
    redirect_to :managment
  end

  def create_oc
    mes = params[:fecha_mes]
    dia = params[:fecha_dia]
    hora = params[:fecha_hora]
    minutos = params[:fecha_minutos]
    comprar = RawMaterial.buy_product_from_supplier(params[:oc_sku], params[:cantidad].to_i, params[:proveedor].to_i, 
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
  	redirect_to :managment
  end

  def notify_deliver
  	puts "notify_deliver"
  	puts params[:oc_cloud_id]
  	puts params[:factura_cloud_id]
  	puts params[:proveedor]
  	redirect_to :managment
  end

  def deliver
  	puts "deliver"
  	puts params[:oc_cloud_id]
  	puts params[:factura_cloud_id]
  	puts params[:proveedor]
    out = Warehouses.despachar_OC(params[:oc_cloud_id])
    puts "OOOOOOOOOORDEN", out
  	redirect_to :managment
  end

  def check_for_availablility
  	puts "check_for_availablility"
    result = Warehouses.product_availability(params[:oc_sku], params[:cantidad].to_i)
    json_response({ret: result})
  end


  def sort_wh
    Warehouses.sort_warehouses
  end

  def authorize
    redirect_to '/login' unless current_user
  end


end
