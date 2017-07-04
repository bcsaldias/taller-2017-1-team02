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

  def promociones
    #@spree_promociones = Spree::Promotion.all

    @owner_active_discounts = Discount.active.where(owner: true).order(sort_column(Discount, "fin") + " " + sort_direction)
    @owner_current_discounts = Discount.current.where(owner: true).order(sort_column(Discount, "fin") + " " + sort_direction)
    @owner_old_discounts = Discount.old.where(owner: true).order(sort_column(Discount, "fin") + " " + sort_direction)


    @others_discounts = Discount.where(owner: false).order(sort_column(Discount, "fin") + " " + sort_direction)

  end

  def oc
    # J: Busca localmente las POrders
    @our_purchase_orders = PurchaseOrder.where(owner: true).where("group_number != -1").order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders = PurchaseOrder.where(owner: nil).where("group_number != -1").order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @our_purchase_orders_created = PurchaseOrder.where(owner: true).where("group_number != -1").where(state: 0).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_created = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 0).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @our_purchase_orders_accepted = PurchaseOrder.where(owner: true).where("group_number != -1").where(state: 1).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_accepted = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 1).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @our_purchase_orders_rejected = PurchaseOrder.where(owner: true).where("group_number != -1").where(state: 2).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_rejected = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 2).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @our_purchase_orders_delivered = PurchaseOrder.where(owner: true).where("group_number != -1").where(state: 3).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_delivered = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 3).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)

    @our_purchase_orders_anuladas = PurchaseOrder.where(owner: true).where("group_number != -1").where(state: 4).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_anuladas = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 4).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
  end

  def ventas
    # state: [:creada, :aceptada, :rechazada, :finalizada, :anulada]
    # J: Busca localmente las POrders

    @purchase_orders = PurchaseOrder.where(owner: nil).where("group_number != -1").order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
    @purchase_orders_created = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 0).order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
    @purchase_orders_accepted = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 1).order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
    @purchase_orders_rejected = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 2).order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
    @purchase_orders_finalizada = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 3).order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
    @purchase_orders_anulada = PurchaseOrder.where(owner: nil).where("group_number != -1").where(state: 4).order(sort_column(PurchaseOrder, "id") + " " + sort_direction)
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
    @invoices = Invoice.where("owner IN (?)", [nil, false]).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)

    @our_invoices_b2b = Invoice.where(owner: true).where.not(cliente: "distribuidor").order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @our_invoices_distribuidor = Invoice.where(owner: true).where(cliente: "distribuidor").order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    # @invoices = Invoice.where(owner: nil).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @invoices_b2b = Invoice.where("owner IN (?)", [nil, false]).where.not(proveedor: "distribuidor").order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @invoices_distribuidor = Invoice.where("owner IN (?)", [nil, false]).where(proveedor: "distribuidor").order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
  end

  def invoice_and_transactions
    puts "Entro al controlador invoice_and_transactions"
    Transaction.refresh
    @transactions_received = Transaction.where(owner: false)#.where.not(state: true)
    @our_invoices = Invoice.where(owner: true).where.not(cliente: "distribuidor")
    .where.not(status: 1).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    # TODO J: Agregar que factura no debe tener orden asociada y que trx no debe tener factura asociada
    puts "Transactions_received: #{@transactions_received.count}"
    puts "Our_invoices: #{@our_invoices.count}"
    @combinaciones = []

    @our_invoices.each do |invoice|
      row = {invoice: invoice.attributes}
      trxs = []
      @transactions_received.each do |trx|
        if trx.invoice
          next
        end

        puts "monto trx = #{trx.monto}"
        puts "monto invoice = #{invoice.iva + invoice.bruto}"
        if trx.monto == invoice.iva + invoice.bruto
          puts "Son iguales los montos!"
          trxs << trx.attributes
        end
      end
      row[:transacciones] = trxs
      @combinaciones << row
    end

    puts @combinaciones

  end

  def asociar_factura_transaccion
    puts "Entre aqui"
    invoice_id_cloud = params[:factura_id_cloud]
    transaction_id_cloud = params[:transaction_id_cloud]
    puts invoice_id_cloud
    puts transaction_id_cloud

    invoice = Invoice.find_by(id_cloud: invoice_id_cloud)
    trx = Transaction.find_by(id_cloud: transaction_id_cloud)

    if !invoice or !trx
      json_response({error: "No encontrada invoice o trx"})
      return
    end
    #Son unibles??
    if trx.monto != invoice.iva + invoice.bruto
      json_response({error: "No son asociables, montos distintos"})
      return
    end

    #TODO test
    puts 1
    factura_pagada = Invoices.pagar_factura(invoice_id_cloud)
    puts 2
    invoice.pagada!
    puts 3
    invoice.transaction_id = trx.id
    puts 4
    invoice.save!
    trx.state = true
    trx.save!
    #TODO j: Conectar factura con trx
    puts "Factura se marca como pagada en el sistema. #{factura_pagada}"
    json_response({ :status => "Exito"}, 201)
  end

  def transaction
    @transactions_ok = Transaction.where(state: true).where(owner: false).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
    @transactions_fail = Transaction.where(state: false).where(owner: false).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
    @our_transactions_ok = Transaction.where(state: true).where(owner: true).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
    @our_transactions_fail = Transaction.where(state: false).where(owner: true).order(sort_column(Transaction, "id_cloud") + " " + sort_direction)
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

  def sprint_5
    @our_purchase_orders_accepted = PurchaseOrder.where(owner: true).where("group_number != -1").where("state IN (?) ", [1,3]).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @purchase_orders_accepted = PurchaseOrder.where(owner: nil).where("group_number != -1").where("state IN (?) ", [1,3]).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    @our_invoices = Invoice.where(owner: true).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)
    @invoices = Invoice.where("owner IN (?)", [nil, false]).order(sort_column(Invoice, "id_cloud") + " " + sort_direction)

    @flujo_compra = []
    @our_purchase_orders_accepted.each do |po|
      row = {po: po.attributes}
      @invoices.each do |i|
        if i.oc_id_cloud == po.id_cloud
          row[:invoice] = i.attributes
          row[:trx] = i.trx.attributes  if i.trx
          break
        end
      end
      @flujo_compra << row
    end

    @flujo_venta = []
    @purchase_orders_accepted.each do |po|
      row = {po: po.attributes}
      @our_invoices.each do |i|
        if i.oc_id_cloud == po.id_cloud
          row[:invoice] = i.attributes
          row[:trx] = i.trx.attributes  if i.trx
          break
        end
      end
      @flujo_venta << row
    end
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
