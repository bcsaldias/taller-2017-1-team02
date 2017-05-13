require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	def test
		#ret = Production.obtener_almacenes
		ret = Production.get_all_stock_warehouse("590baa76d6b4ec000490255f")
		json_response({response: ret})
	end

end
