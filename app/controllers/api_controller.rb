require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries
	def test
		ret =     comprar = RawMaterial.buy_product_from_supplier("7", 50, 7, 
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
		json_response({response: ret})
	end

	def test2
		ret =     comprar = RawMaterial.buy_product_from_supplier("7", 50, 2, 
                          needed_date = Tiempo.tiempo_a_milisegundos(5, 16, 22, 00)) #mes, dia, hora, minuto
		json_response({response: ret})
	end

end
