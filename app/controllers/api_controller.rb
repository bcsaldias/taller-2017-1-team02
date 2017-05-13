require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries


	def test
		ret = Production.try_put("2", 150)
		#ret = Production.get_stock("590baa76d6b4ec000490255f", 41)
		json_response({response: ret})
	end

end
