require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries
	include Invoices

	def test2
		acc = Rails.configuration.environment_ids['bank_id']
		puts acc
		t0 = Tiempo.tiempo_a_milisegundos(05, 15, 23, 00)
		t1 = Tiempo.tiempo_a_milisegundos(05, 26, 23, 00)
		ret = Bank.get_card(t0, t1, acc, 10 )
		json_response({response: ret})
	end

	def test3
		tid = Rails.configuration.environment_ids['team_id']
		ret = Invoices.crear_boleta(tid, "2", 10)
		json_response({response: ret})
	end

	def test
		json_response({response: Factory.get_account})
	end
	
	def test4
		ret =     comprar = RawMaterial.buy_product_from_supplier("7", 50, 7,
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
		json_response({response: ret})
	end

  def test6
		warehouses_id = Warehouses.get_warehouses_id
		stock_general_sku = Production.get_stock(warehouses_id['general'], "2")

		puts "Aqui imprimo el stock"
		puts stock_general_sku
		puts "Ya imprimi el stock"
  end

	# Metodo que permite verificar que la informacion local sea consistente con server
	def validacion_local_servidor
		counter_our_po = 0
		counter_rec_po = 0

		@our_purchase_orders = PurchaseOrder.all.where(owner: true)
		@our_purchase_orders.each do |our_po|
			counter_our_po += 1
			id_cloud = our_po.id_cloud
			cloud_po = Sales.get_purchase_order(id_cloud)
			json_response({resp: "error_state", in: "our po"}) if our_po.state != cloud_po["estado"]
			json_response({resp: "error_sku", in: "our po"}) if our_po.product_sku != cloud_po["sku"]
			json_response({resp: "error_quant", in: "our po"}) if our_po.quantity != cloud_po["cantidad"]
		end

		@received_purchase_orders = PurchaseOrder.all.where(owner: nil)
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

end
