require 'json'
require 'net/http'
require 'base64'
require 'net/sftp'

require 'bunny'


class ApiController < ApplicationController

	include Queries
	include Invoices
	include Purchases
	include Promotions
	include Bank

    def update_prices


     Product.all.each do |product|
      product.price = 184 if product.sku == "2"
      product.price = 16546 if product.sku == "6"
      product.price = 454 if product.sku == "8"
      product.price = 533 if product.sku == "14"
      product.price = 310 if product.sku == "20"
      product.price = 178 if product.sku == "26"
      product.price = 419 if product.sku == "39"
      product.price = 11470 if product.sku == "40"
      product.price = 9768 if product.sku == "41"
      product.price = 1803 if product.sku == "49"
      product.save!
     end

     Spree::Product.all.each do |product|
      product.price = 184 if product.name == "Huevo"
      product.price = 16546 if product.name == "Crema"
      product.price = 454 if product.name == "Trigo"
      product.price = 533 if product.name == "Cebada"
      product.price = 310 if product.name == "Cacao"
      product.price = 178 if product.name == "Sal"
      product.price = 419 if product.name == "Uva"
      product.price = 11470 if product.name == "Queso"
      product.price = 9768 if product.name == "Suero de Leche"
      product.price = 1803 if product.name == "Leche Descremada"
      product.save!
     end

     json_response({ret: 'ok'})

    end


    def get_ofertas

        ret = Promotions.get_ofertas

        #ret =  Promotions.update("test_huevo_1")#,
                                  #Time.now,
                                  #Time.now + 3.hours,
                                  #"2", 180, true)

        json_response(ret)

    end

	def get_ofertasX
      next_path = 'https://graph.facebook.com/oauth/access_token?'
      fb_exchange_token = ''
      params={
        'grant_type'=>'fb_exchange_token',           
        'client_id'  =>  '1359547220792049',
        'client_secret'  =>  '64090baac0aa284bf230439e647900e4',
        'fb_exchange_token' => fb_exchange_token
      } 

      ret =  HTTParty.get(next_path, :query => params )
      json_response(ret.body)
        
    end

	def test_old01
		ret = Warehouses.move_A_B('general', 'despacho', 10)
		json_response({ret:  ret })

	end

	def test
		ret = Invoices.anular_factura("5947005016d24d000466fb56", "OC rechazada")
		ret2 = 0# Bank.transfer(17578800, "5910c0910e42840004f6e689", "5910c0910e42840004f6e68a")
		json_response({ret: ret, r2: ret2})
	end

	def test_old00

		voucher = Voucher.where(id_cloud: "59302fe5e7efa40004329ecb").first
		Production.save_order_for_delivering(voucher)
		json_response({ret: voucher})
	end

	def testshak

		lines = Spree::LineItem.all
		lines.each do |line|
			puts "cantidad " + line.quantity.to_s
			puts "sku " + Spree::Variant.find(line.variant_id).sku.to_s
		end
		json_response({orders: lines})

	end



	def test55
		## FIXME
		transactions_query = Bank.get_our_card
		transactions =  transactions_query['data']
		total = transactions_query['total'].to_i

		transactions.each do |trx|
			puts trx['origen']
			puts trx['monto']
		end
		#tomar la última transacción y ver si el monto es igual al de la boleta
		#además del proveedor
		json_response({response: transactions})
	end

	def test_coke
		ret = Bank.get_transaction("592b2d1d8794840004e936cd")
		json_response({response: ret})
	end

	include Sales

	def test2
		acc = Rails.configuration.environment_ids['bank_id']
		puts acc
		t0 = Tiempo.tiempo_a_milisegundos(05, 15, 23, 00)
		t1 = Tiempo.tiempo_a_milisegundos(05, 26, 23, 00)
		ret = Bank.get_card(t0, t1, acc, 10 )
	end

	def testx
		#ret = Invoices.emitir_factura("592c1e278794840004e95ca4")
		#ret = Invoices.enviar_confirmacion_factura("592c24eb8794840004e95d0e")
		acc = Rails.configuration.environment_ids['bank_id']

		#ret = Invoices.enviar_factura("592c24eb8794840004e95d0e", acc)

		ret = Bank.transfer(10000000000, acc, acc)

		json_response({response: ret})

	end

	def testbb
		tid = Rails.configuration.environment_ids['team_id']

		sup = Supplier.get_by_id_cloud(tid)

		ret = Purchases.create_purchase_order("590baa00d6b4ec0004902468", sup, "2",
		 							3493314596281, 10, 100,
		 							"b2b", "default-note1")
		json_response({response: ret.code})
	end

	def test3
		tid = Rails.configuration.environment_ids['team_id']
		ret = Invoices.crear_boleta(tid, "2", 10)
		json_response({response: ret})
	end


	def testj1
		ret =     comprar = RawMaterial.buy_product_from_supplier("7", 50, 7,
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
		json_response({response: ret})
	end

  def testj2
		warehouses_id = Warehouses.get_warehouses_id
		stock_general_sku = Production.get_stock(warehouses_id['general'], "2")

		puts "Aqui imprimo el stock"
		puts stock_general_sku
  end

	def testj3
		puts Time.now
		warehouses_id = Warehouses.get_warehouses_id
		stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
    stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])

    puts "General: #{stock_general}"
    puts "Pregeneral: #{stock_pregeneral}"
    puts "Recepcion: #{stock_recepcion}"
    puts "Pulmon: #{stock_pulmon}"
    puts "Despacho: #{stock_despacho}"
		json_response({Despacho: "Finito"})

	end

	def testj4
		puts "Entro a controller"
		ret = Warehouses.check_and_restore_stock
		json_response({Despacho: ret})
	end

	# def testj4
	# 	warehouse_id = "590baa76d6b4ec000490255e"
	# 	sku = "26"
	# 	cant = Production.get_stock(warehouse_id, sku)
	# 	#puts Production.get_warehouses()
	# 	#json_response({Despacho: "Des", sku: sku})
	# 	puts cant
	# 	json_response({Despacho: cant, sku: sku})
	# end

	def actualizar_deadlines_purchase_orders
		PurchaseOrder.all.each do |po|
			order = Sales.get_purchase_order(po.id_cloud)
			po.deadline = order['fechaEntrega']
	    po.save!
		end
		json_response({response: "Finalizado"})

	end

	def tiempo
		milisecs = Tiempo.tiempo_a_milisegundos(5, 28, 19, 15)
		json_response({response: milisecs})
	end

	# Metodo que permite verificar que la informacion local sea consistente con server
	def validacion_local_servidor
		counter_our_po = 0
		counter_rec_po = 0

		@our_purchase_orders = PurchaseOrder.where(owner: true)
		@our_purchase_orders.each do |our_po|
			counter_our_po += 1
			id_cloud = our_po.id_cloud
			cloud_po = Sales.get_purchase_order(id_cloud)
			json_response({resp: "error_state", in: "our po"}) if our_po.state != cloud_po["estado"]
			json_response({resp: "error_sku", in: "our po"}) if our_po.product_sku != cloud_po["sku"]
			json_response({resp: "error_quant", in: "our po"}) if our_po.quantity != cloud_po["cantidad"]
		end

		@received_purchase_orders = PurchaseOrder.where(owner: nil)
		@received_purchase_orders.each do |rec_po|
			counter_rec_po +=1
			id_cloud = rec_po.id_cloud
			cloud_po = Sales.get_purchase_order(id_cloud)
			json_response({resp: "error_state", in: "rec po"}) if rec_po.state != cloud_po["estado"]
			json_response({resp: "error_sku", in: "rec po"}) if rec_po.product_sku != cloud_po["sku"]
			json_response({resp: "error_quant", in: "rec po"}) if rec_po.quantity != cloud_po["cantidad"]
		end
		json_response({response: "Todo Ok",
			our_po_revisadas: counter_our_po, received_po_revisadas: counter_rec_po}) if !performed?
	end
	# def test2
	# 	acc = Rails.configuration.environment_ids['bank_id']
	# 	puts acc
	# 	t0 = Tiempo.tiempo_a_milisegundos(05, 15, 23, 00)
	# 	t1 = Tiempo.tiempo_a_milisegundos(05, 26, 23, 00)
	# 	ret = Bank.get_card(t0, t1, acc, 10 )
	#
	# def test
	# 	tid = Rails.configuration.environment_ids['team_id']
	#
	# 	#ret = Invoices.emitir_factura("59288d75212344000408bdf4")
	# 	ret = Invoices.anular_factura("59288dce212344000408bdf5", "porque si")
	# 	json_response({response: ret})
	# end
	#
	# def test3
	# 	tid = Rails.configuration.environment_ids['team_id']
	# 	ret = Invoices.crear_boleta(tid, "2", 10)
	# 	json_response({response: ret})
	# end
	#
	#
	# def testj1
	# 	ret =     comprar = RawMaterial.buy_product_from_supplier("7", 50, 7,
  #                         needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
	# 	json_response({response: ret})
	# end
	#
  # def testj2
	# 	warehouses_id = Warehouses.get_warehouses_id
	# 	stock_general_sku = Production.get_stock(warehouses_id['general'], "2")
	#
	# 	puts "Aqui imprimo el stock"
	# 	puts stock_general_sku
  # end
	#
	# # Metodo que permite verificar que la informacion local sea consistente con server
	# def validacion_local_servidor
	# 	counter_our_po = 0
	# 	counter_rec_po = 0
	#
	# 	@our_purchase_orders = PurchaseOrder.where(owner: true)
	# 	@our_purchase_orders.each do |our_po|
	# 		counter_our_po += 1
	# 		id_cloud = our_po.id_cloud
	# 		cloud_po = Sales.get_purchase_order(id_cloud)
	# 		json_response({resp: "error_state", in: "our po"}) if our_po.state != cloud_po["estado"]
	# 		json_response({resp: "error_sku", in: "our po"}) if our_po.product_sku != cloud_po["sku"]
	# 		json_response({resp: "error_quant", in: "our po"}) if our_po.quantity != cloud_po["cantidad"]
	# 	end
	#
	# 	@received_purchase_orders = PurchaseOrder.where(owner: nil)
	# 	@received_purchase_orders.each do |rec_po|
	# 		counter_rec_po +=1
	# 		id_cloud = rec_po.id_cloud
	# 		cloud_po = Sales.get_purchase_order(id_cloud)
	# 		json_response({resp: "error_state", in: "rec po"}) if rec_po.state != cloud_po["estado"]
	# 		json_response({resp: "error_sku", in: "rec po"}) if rec_po.product_sku != cloud_po["sku"]
	# 		json_response({resp: "error_quant", in: "rec po"}) if rec_po.quantity != cloud_po["cantidad"]
	# 	end
	#
	#
	# 	json_response({response: "Todo Ok",
	# 		our_po_revisadas: counter_our_po, received_po_revisadas: counter_rec_po}) if !performed?
	# end

end
