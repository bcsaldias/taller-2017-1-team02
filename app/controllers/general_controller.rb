#include HTTParty
class GeneralController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc, :sort_column, :sort_direction
  include Warehouses
  include RawMaterial
  require 'json'


  def index
  end

  def vouchers
    @vouchers = Voucher.all.order(sort_column(Voucher, "id_cloud") + " " + sort_direction)
  end

  def oc
    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.where(owner: true).where("group_number != -1").order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders = PurchaseOrder.where(owner: nil).where("group_number != -1").order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
  end

  def ventas
    # J: Busca localmente las POrders
    @purchase_orders = PurchaseOrder.where(owner: nil).where("group_number != -1").order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
  end


  def ftp_oc
    @total_ftp = PurchaseOrder.where("group_number == -1")

    @created_ftp  = @total_ftp.where(state: 0).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @created_can_ftp = PurchaseOrder.can_accept_ftp.order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @created_cannot_ftp = PurchaseOrder.cannot_accept_ftp.order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @accepted_ftp  = @total_ftp.where(state: 1).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @rejected_ftp  = @total_ftp.where(state: 2).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @delivered_ftp  = @total_ftp.where(state: 3).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
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

  # TODO
  def accept_invoice
    puts "Entre al aceptar o rechazar invoice"
    @end =  nil
    if params[:status] == "Aceptar"
      puts "Entre al aceptar fact"
      @end = Invoices.enviar_confirmacion_factura(params[:cloud_id])
      # @end = Sales.accept_purchase_order(params[:cloud_id])
    elsif params[:status] == "Rechazar"
      puts "Entre al Rechazar fact"
      @end = Invoices.enviar_rechazo_factura(params[:cloud_id], cause='no aceptable')

      # @end = Sales.reject_purchase_order(params[:cloud_id], cause='no alcanzamos')
    end
    json_response({invoice:params[:cloud_id], status:params[:status]})
  end

  def accept_ftp
    @end =  nil
    if params[:status] == "Aceptar"
      @end = Sales.accept_ftp_order(params[:cloud_id])
    elsif params[:status] == "Rechazar"
      @end = Sales.reject_ftp_order(params[:cloud_id], cause='no alcanzamos')
    end
    json_response({oc:params[:cloud_id], status:params[:status]})
  end


  def invoices
    @our_invoices = Invoice.where(owner: true).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @invoices = Invoice.where(owner: nil).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
  end

  def transaction
    @transactions_ok = Transaction.where(state: true).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
    @transactions_fail = Transaction.where(state: false).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
  end

  def queue
    @production_orders = ProductionOrder.where(queued: true).order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
    @purchase_orders = PurchaseOrder.where(queued: true).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @vouchers = Voucher.where(queued: true).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
  end

  def activate_queue
    puts "ACTIVANDO COLA"
    ret = Warehouses.activate_queue
    json_response({ret: ret})
  end

  def production
    @personal_account = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
    @production_orders = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
    @factory = ProductionOrder.all.order(sort_column(ProductionOrder, "product_sku") + " " + sort_direction)
  end

  def despacho

    warehouses_id = Warehouses.get_warehouses_id
    #@stock = Production.get_all_stock_warehouse("590baa76d6b4ec000490255f") Bodega general
    @stock = Production.get_all_stock_warehouse(warehouses_id['despacho']) # Bodega despacho
    @products = Product.all
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
