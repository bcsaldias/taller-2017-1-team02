#include HTTParty
class ManagmentsController < ApplicationController
  before_action :authorize
  helper_method :sort_wh, :notify_deliver, :deliver, :check_for_availablility, :create_oc, :accept_oc, :sort_column, :sort_direction
  include Warehouses
  include RawMaterial
  include FtpOrders
  require 'json'

  def index
    @being_delivered = PurchaseOrder.where(delivering: true).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    pending_vouchers = VoucherStock.all#where("quantity = ? OR quantity_done = ?", value, value)

    #show_stocks_vouchers = []
    vouchers = []
    vouchers_id = []
    pending_vouchers.each do |pv|
      if pv.quantity != pv.quantity_done

        if not vouchers_id.include?(pv.voucher_id)
          voucher = Voucher.find(pv.voucher_id)#.order(sort_column(Voucher, "id_cloud") + " " + sort_direction)

      	  if voucher.status != "despachada"
            		vouchers << voucher
            		vouchers_id << pv.voucher_id
      	  end
          #show_stocks_vouchers <<
        end
        #pv.voucher_id
      end
    end

    @show_vouchers =  Voucher.where('id IN (?)', vouchers_id).order(sort_column(Voucher, "id_cloud") + " " + sort_direction)
  end

  def despachar_boleta
    voucher_id = params[:voucher_id]
    # METER A COLA
    # cuando se crean también: se hace Production.save_order_for_delivering
    #ret = Production.deliver_order_to_address(voucher_id)
    voucher = Voucher.find(voucher_id.to_i)
    voucher.queued = true
    voucher.save!
    ret = voucher.queued
    json_response({voucher_id: voucher_id, queued: ret})
  end

  def stocks_force_update
    req = Product.force_update
    json_response({req: req})
  end

  def sent_production
    puts params[:oc_sku]
    puts params[:cantidad_raw_material]

    # METER A COLA si procesado
    req = Factory.hacer_pedido_interno(params[:oc_sku],
                      params[:cantidad_raw_material].to_i)
    
    #req = false
    json_response({req: req})
  end

  def detener_despacho
    being_delivered = PurchaseOrder.where(id_cloud: params[:cloud_id]).first
    #being_delivered.delivering = false
    #being_delivered.save!
    json_response({oc: params[:cloud_id], delivering: being_delivered.delivering})
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

  def pay_invoice
    puts "pagar factura"
    puts params[:factura_cloud_id]
    payment = Invoices.pay_invoice(params[:factura_cloud_id])
    puts payment
    json_response({ret: payment})
  end

  def deliver
    puts "deliver"
    puts params[:oc_cloud_id]
    puts params[:factura_cloud_id]
    puts params[:proveedor]
    order = PurchaseOrder.where(id_cloud: params[:oc_cloud_id]).first
    # METER A COLA cuando se acepta se mete a la cola
    # ojo que aun no veo la factura FIXEME
    #order.delivering = true
    #order.save!
    order.queued = true
    order.save!
    #out = Warehouses.despachar_OC(params[:oc_cloud_id])
    out = true
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

  def refresh_ftp
    ret =  FtpOrders.check_orders
    json_response({ret: ret})
  end


  def deliver_ftp
    puts "deliver ftp"
    order = PurchaseOrder.where(id_cloud: params[:oc_cloud_id]).first
    order.queued = true #el accept lo mete
    order.save!
    # METER A COLA
    # out = Production.deliver_ftp_order(params[:oc_cloud_id])
    out = order.queued
    json_response({queued: out})
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
    transactions.each do |trx|
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

    PurchaseOrder.where("group_number != -1").each do |po| #where(owner: true)
      id_cloud = po.id_cloud
      cloud_po = Sales.get_purchase_order(id_cloud)


      if po.owner != true and po.team_id_cloud != cloud_po["cliente"]
        po.team_id_cloud = cloud_po["cliente"]
        po.save!
        supp = Supplier.get_by_id_cloud(cloud_po['cliente'])
        if supp
          po.group_number = supp.id
          po.save!
        end
        refreshed = true
      end

      if po.owner == true

        if po.team_id_cloud != cloud_po["proveedor"]
          po.team_id_cloud = cloud_po["proveedor"]
          po.save!
          supp = Supplier.get_by_id_cloud(cloud_po['proveedor'])
          if supp
            po.group_number = supp.id
            po.save!
          end
          refreshed = true
        end

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

        if po.true_quantity_done != cloud_po["cantidadDespachada"]
          po.true_quantity_done = cloud_po["cantidadDespachada"]
          po.save!
          refreshed = true
        end
      end

    end

    PurchaseOrder.where("group_number == -1").each do |po|
        id_cloud = po.id_cloud
        cloud_po = Sales.get_purchase_order(id_cloud)
        puts "sfpt - Local: #{po.state} - Nube: #{cloud_po["estado"]}"
        if po.state != cloud_po["estado"]
          po.state = cloud_po["estado"]
          po.save!
          refreshed = true
          puts "Modifico State: #{po.state}"
        end
    
        if po.true_quantity_done != cloud_po["cantidadDespachada"]
          po.true_quantity_done = cloud_po["cantidadDespachada"]
          po.save!
          refreshed = true
        end

    end
    
    json_response({resp: "Todo estaba OK", cantidad_oc: cant }) and return if !refreshed
    json_response({response: "Actualizado"})
  end

  def refresh_balance

    response = Bank.get_account(Rails.configuration.environment_ids['bank_id'])
    puts response

    @saldo = response.first["saldo"]

    ## FIXME J:
    @being_delivered = PurchaseOrder.where(delivering: true).order(sort_column(PurchaseOrder, "product_sku") + " " + sort_direction)
    pending_vouchers = VoucherStock.all#where("quantity = ? OR quantity_done = ?", value, value)

    #show_stocks_vouchers = []
    vouchers = []
    vouchers_id = []
    pending_vouchers.each do |pv|
      if pv.quantity != pv.quantity_done

        if not vouchers_id.include?(pv.voucher_id)
          voucher = Voucher.find(pv.voucher_id)#.order(sort_column(Voucher, "id_cloud") + " " + sort_direction)

      	  if voucher.status != "despachada"
            		vouchers << voucher
            		vouchers_id << pv.voucher_id
      	  end
          #show_stocks_vouchers <<
        end
        #pv.voucher_id
      end
    end

    @show_vouchers =  Voucher.where('id IN (?)', vouchers_id).order(sort_column(Voucher, "id_cloud") + " " + sort_direction)
    ##

    render "index.html.erb"
  end

  def move_despacho_general
    puts "Entre mi metodo desp"
    Warehouses.move_despacho_general
  end

  def move_recepcion_general
    puts "Entre mi metodo gen"
    Warehouses.move_recepcion_general
  end

  def stop_warehouses_reorder
    Rails.application.config.able_to_reorder = false
    json_response({response: "Todos los REORDENAR se DETENDRAN en breve"})
  end

  def authorize
    redirect_to '/login' unless current_user
  end

  private

  def sort_column(nombre, defecto)
    nombre.column_names.include?(params[:sort]) ? params[:sort] : defecto
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
