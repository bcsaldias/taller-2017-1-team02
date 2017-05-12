require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	def test
		almacenes = Production.obtener_almacenes
		json_response({"almacenes": almacenes})
	end

end
