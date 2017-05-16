#include HTTParty
class ManagmentsController < ApplicationController
  before_filter :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc
  include Warehouses
  include RawMaterial


  def index
    @our_purchase_orders = PurchaseOrder.all.where(owner: true)
    @purchase_orders = PurchaseOrder.all.where(owner: nil)
    @production_orders = ProductionOrder.all
    @factory = ProductionOrder.all

  end

  def sent_production
  	puts params[:oc_sku]
  	puts params[:cantidad]

  	redirect_to :managment
  end

  def create_oc
    comprar = RawMaterial.buy_product_from_supplier(params[:oc_sku], params[:cantidad].to_i, params[:proveedor].to_i, 
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 18, 00))

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
  	redirect_to :managment
  end

  def check_for_availablility
  	puts "check_for_availablility"
  	puts params[:oc_sku]
  	puts params[:cantidad]
  	redirect_to :managment

  end


  def sort_wh
    Warehouses.sort_warehouses
  end

  def authorize
    redirect_to '/login' unless current_user
  end


end
