require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test


		ret = Production.get_warehouses


		json_response({response: ret})
	end

end
