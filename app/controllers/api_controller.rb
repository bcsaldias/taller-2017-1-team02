require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries
	include Invoices
	include Purchases
	include Sales

	def test2
		acc = Rails.configuration.environment_ids['bank_id']
		puts acc
		t0 = Tiempo.tiempo_a_milisegundos(05, 15, 23, 00)
		t1 = Tiempo.tiempo_a_milisegundos(05, 26, 23, 00)
		ret = Bank.get_card(t0, t1, acc, 10 )
	end

	def test
		#tid = Rails.configuration.environment_ids['team_id']
		
		#ret = Invoices.emitir_factura("59288d75212344000408bdf4")
		ret = Invoices.obtener_factura("5928ae6a212344000408bf78")
		#ret = Invoices.anular_factura("59288dce212344000408bdf5", "porque si")
		# ret = Purchases.create_purchase_order("590baa00d6b4ec0004902468", "590baa00d6b4ec0004902463", "2",
		# 							"2036-05-01T00:29:56.281Z", 10, 100,
		# 							"b2b", "default-note1")
		 #ret = Sales.get_purchase_order("59288d75212344000408bdf4")
		json_response({response: ret})
	end

	def test3
		tid = Rails.configuration.environment_ids['team_id']
		ret = Invoices.crear_boleta(tid, "2", 10)
		json_response({response: ret})
	end

end
