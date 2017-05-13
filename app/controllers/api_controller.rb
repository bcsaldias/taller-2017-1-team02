require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test

		#ret = Tiempo.tiempo_a_milisegundos(5,15,0,0)
		ret = Sales.accept_purchase_order("5917658a1f734200049c0fa5")

		json_response({response: ret})
	end

end
