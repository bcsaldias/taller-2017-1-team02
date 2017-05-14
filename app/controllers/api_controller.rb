require 'json'
require 'net/http'
require 'base64'
class ApiController < ApplicationController

	include Queries

	def test
		#ret = Factory.fabricate_without_paying("41", 200)
		#ret = Factory.get_account
		#ret = Production.move_stock_external("590baa76d6b4ec000490255d",
		#									"590baa76d6b4ec000490262a",
		#									 "32", 1)
		#ret = Production.get_stock("590baa76d6b4ec000490255f", 41)
		#ret = Production.get_warehouses
		#ret = Production.get_stock("590baa76d6b4ec000490255f","41")
		#ret = Production.move_stock("590baa76d6b4ec000490255e", "590baa76d6b4ec000490262a")
		#ret = Production.get_stock("590baa76d6b4ec000490255e", "41")
		#ret = Tiempo.tiempo_a_milisegundos(5,15,0,0)
		#ret = Sales.accept_purchase_order("59177e251f734200049c0fab") #5917658a1f734200049c0fa5 #59177b9b1f734200049c0fa9 59177aa91f734200049c0fa8
		#ret = Sales.reject_purchase_order("59177e251f734200049c0fab", cause='test_cause') 
		#ret = Sales.recepcionar_purchase_order
		#ret = Sales.get_purchase_order("59177e251f734200049c0fab")
		
		#ret = Sales.create_purchase_order(  cliente = "5910c0910e42840004f6e684",
		#								    proveedor = "590baa00d6b4ec0004902463",
		#								    sku = "2",
		#								    fechaEntrega = 2493314596281,
		#								    cantidad = "100",
		#								    precioUnitario = "100",
		#								    canal = "b2b", notas = "hola"
		#								)

		# 590baa76d6b4ec000490255d
		# 590baa76d6b4ec000490255f
		# 590baa76d6b4ec000490265e

		ret = PurchaseOrder.all#.accept_purchase_order("5917d8581f734200049c0fc4")
		#ret = Production.get_all_stock_warehouse("590baa76d6b4ec000490255d")
		json_response({response: ret})
	end

end
