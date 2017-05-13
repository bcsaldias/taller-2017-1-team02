require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test

		#ret = Tiempo.tiempo_a_milisegundos(5,15,0,0)
		#ret = Sales.accept_purchase_order("59177e251f734200049c0fab") #5917658a1f734200049c0fa5 #59177b9b1f734200049c0fa9 59177aa91f734200049c0fa8
		#ret = Sales.reject_purchase_order("59177e251f734200049c0fab", cause='test_cause') 
		#ret = Sales.recepcionar_purchase_order
		ret = Sales.get_purchase_order("59177e251f734200049c0fab")
		json_response({response: ret})
	end

end
