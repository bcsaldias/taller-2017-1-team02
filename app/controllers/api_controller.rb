require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries


	def test
		#ret = Factory.fabricate_without_paying("2dwwd", 150)
		#ret = Factory.get_account
		#ret = Production.move_stock_external("590baa76d6b4ec000490255d",
		#									"590baa76d6b4ec000490262a",
		#									 "32", 1)
		#ret = Production.get_stock("590baa76d6b4ec000490255f", 41)
		#ret = Production.get_warehouses
		#ret = Production.get_stock("590baa76d6b4ec000490255f","41")
		#ret = Production.move_stock("590baa76d6b4ec000490255e", "590baa76d6b4ec000490262a")
		#ret = Production.get_stock("590baa76d6b4ec000490255e", "41")

		#ret = Sales.create_purchase_order(
		#									cliente = "5910c0910e42840004f6e684",
		#									proveedor = "590baa00d6b4ec0004902463",
		#									sku = "2",
		#									fechaEntrega = 2493314596281,
		#									cantidad = "100",
		#									precioUnitario = "100",
		#									canal = "b2b",
		#									notas = "test"
		#								)

		#json_response({response: ret})
	end

end
