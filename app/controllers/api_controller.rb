require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test
		#ret = Production.obtener_almacenes
		ret = Sales.get_purchase_order('0')
		json_response({response: ret})
	end

end
