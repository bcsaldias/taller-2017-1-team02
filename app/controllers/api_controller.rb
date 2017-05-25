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

end
 
