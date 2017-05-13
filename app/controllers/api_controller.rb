require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries


	def test
		#ret = Factory.fabricate_without_paying("2dwwd", 150)
		ret = Factory.get_account
		#ret = Production.move_stock_external("590baa76d6b4ec000490255d",
		#									"590baa76d6b4ec000490262a",
		#									 "32", 1)
		#ret = Production.get_stock("590baa76d6b4ec000490255f", 41)
		#ret = Production.get_warehouses
		#ret = Production.get_stock("590baa76d6b4ec000490255f","41")
		#ret = Production.move_stock("590baa76d6b4ec000490255e", "590baa76d6b4ec000490262a")
		#ret = Production.get_stock("590baa76d6b4ec000490255e", "41")
		json_response({response: ret})
	end

end
