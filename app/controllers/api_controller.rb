require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test

		ret = Sales.create_purchase_order(cliente = ,
									proveedor = ,
									sku = ,
									fechaEntrega, cantidad, precioUnitario,
									canal, notas)

		json_response({response: ret})
	end

end
