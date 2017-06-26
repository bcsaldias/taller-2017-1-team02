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
    @old_discounts = Discount.old.order(sort_column(Discount, "fin") + " " + sort_direction)
    @current_discounts = Discount.current.order(sort_column(Discount, "fin") + " " + sort_direction)

    @spree_promociones = Spree::Promotion.all

    ## Facebook
    #a_t = 'EAATUgEEmkvEBANZAsBPsKn7NdGFVwDnUuNnrSDnbjZCKTDP7u9acmefzm6YUxBwW2a1QytMon37qH9j36NJ73DBzYSlkBzHwQkYQ2teq3nkyZAMf9shmHdBLv1DjfRnG1lyj9hPOjHA9qFXVNcxBYBM1ZAAeetJqBSIMeIjZBZCeiebzTgBv6ZAaAVZBnt3EmRMZD'
    #@user_graph = Koala::Facebook::API.new(a_t)

    # retrieve collection fo all your managed pages: returns collection of hashes with page id, name, category, access token and permissions
    #pages = @user_graph.get_connections('me', 'accounts')
    #puts pages
    # get access token for first page
    #first_page_token = pages.first['access_token']
    #@page_graph = Koala::Facebook::API.new(first_page_token)
    #puts @page_graph

    #@page_graph.get_object('me') # I'm a page
    #@page_graph.get_connection('me', 'feed') # the page's wall
    #@page_graph.put_wall_post('4to post') # post as page, requires new publish_pages permission

    # path = Rails.root + 'public/assets/images/products/' + sku_image[product.sku]
    #/{"463352627338821"}/photos/
    # options = {
    #   :message => "Cacao",
    #   :picture => "http://i.vanidades.com/dam/estilo-de-vida/14/09/683531-beneficios-cacao-3008x2000.jpg.imgw.1280.1280.jpeg"
    # }
    # @page_graph.put_picture(options[:picture], {:caption => options[:message]})

    ## twitter

    @twitter = Twitter::REST::Client.new do |config|
      # config.consumer_key = ENV['CONSUMER_KEY']
      # config.consumer_secret = ENV['CONSUMER_SECRET']
      # config.access_token = request.env["omniauth.auth"][:credentials][:token]
      # config.access_token_secret = request.env["omniauth.auth"][:credentials][:secret]
      config.consumer_key = 'MReVzy5O7qXJ0nxEXwrekTjI8'
      config.consumer_secret =  'YqLRtE2ftXOANqoppx8HHB6DyXNHyRAzxxQprNE90hfgxRY5dY'
      config.access_token =   '878628188464836608-4rtAtrGCHOicZLvfsPUZL8NxC0KezdI'
      config.access_token_secret = 'R8GI4W4pY8iokBZ7Yfj6rLcAItRS5XgfqlhKvnIlqDEur'
    end

    
    @twitter.update("Primer post")

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
