require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries


	def test
		#ret = Factory.fabricate_without_paying("2dwwd", 150)
		ret = Factory.get_account
		#ret = Production.move_stock("590baa76d6b4ec000490255e","590baa76d6b4ec0004902625")
		#ret = Production.get_stock("590baa76d6b4ec000490255f", 41)
		json_response({response: ret})
	end

end
