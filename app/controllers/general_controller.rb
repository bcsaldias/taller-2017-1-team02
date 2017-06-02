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

    @vouchers = Voucher.all
  end

  def vouchers
    @vouchers = Voucher.all.order(sort_column(Voucher, "id_cloud") + " " + sort_direction)

  end

  def oc
    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.where(owner: true).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders = PurchaseOrder.where(owner: nil).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

  end

  def invoices
    @our_invoices = Invoice.where(owner: true).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @invoices = Invoice.where(owner: nil).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
  end

  def transaction
    @transactions_ok = Transaction.where(state: true).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
    @transactions_fail = Transaction.where(state: false).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
  end

  def production
    @personal_account = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
    @production_orders = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
    @factory = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
  end

  def authorize
    redirect_to '/login' unless current_user
  end

  private

  # CAMBIAR A INDICE !!
  
  def sort_column(nombre, defecto)
    nombre.column_names.include?(params[:sort]) ? params[:sort] : defecto
  end

  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
