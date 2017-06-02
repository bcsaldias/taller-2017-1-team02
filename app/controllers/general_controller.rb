#include HTTParty
class GeneralController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc, :sort_column, :sort_direction
  include Warehouses
  include RawMaterial
  require 'json'


  def index
    #@our_purchase_orders = PurchaseOrder.our_oc
    #@purchase_orders = PurchaseOrder.requested

    @personal_account = ProductionOrder.all


    @production_orders = ProductionOrder.all
    @factory = ProductionOrder.all

    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.where(owner: true)
    @purchase_orders = PurchaseOrder.where(owner: nil)

    @our_invoices = Invoice.where(owner: true)
    @invoices = Invoice.where(owner: nil)

    @transactions_ok = Transaction.where(state: true)
    @transactions_fail = Transaction.where(state: false)
    
  end

  def oc
    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.where(owner: true).order(sort_column + " " + sort_direction)
    @purchase_orders = PurchaseOrder.where(owner: nil).order(sort_column + " " + sort_direction)

  end

  def invoices
    @our_invoices = Invoice.where(owner: true)
    @invoices = Invoice.where(owner: nil)
  end

  def transaction
    @transactions_ok = Transaction.where(state: true)
    @transactions_fail = Transaction.where(state: false)
  end

  def production
    @personal_account = ProductionOrder.all
    @production_orders = ProductionOrder.all
    @factory = ProductionOrder.all
  end

  def authorize
    redirect_to '/login' unless current_user
  end

  private
  
  def sort_column
    PurchaseOrder.column_names.include?(params[:sort]) ? params[:sort] : "product_sku"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
