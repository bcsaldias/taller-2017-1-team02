#include HTTParty
class GeneralController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc
  include Warehouses
  include RawMaterial
  require 'json'


  def index
    #@our_purchase_orders = PurchaseOrder.our_oc
    #@purchase_orders = PurchaseOrder.requested
    @production_orders = ProductionOrder.all
    @factory = ProductionOrder.all

    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.all.where(owner: true)
    @purchase_orders = PurchaseOrder.all.where(owner: nil)
  end

  def authorize
    redirect_to '/login' unless current_user
  end

end
