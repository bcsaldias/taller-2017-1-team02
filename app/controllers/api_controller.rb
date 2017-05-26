require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries
	include Invoices
	include Purchases

	def test
		tid = Rails.configuration.environment_ids['team_id']
		
		#ret = Invoices.emitir_factura("59288d75212344000408bdf4")
		ret = Invoices.anular_factura("59288dce212344000408bdf5", "porque si")
		json_response({response: ret})
	end


end
 