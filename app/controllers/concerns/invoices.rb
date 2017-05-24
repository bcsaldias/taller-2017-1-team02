module Invoices
	include Queries
  	require 'json'

  	def self.crear_boleta(origin_group_id, private_client_id, amount)
    	body = {'proveedor' => origin_group_id, 
    			'cliente' => private_client_id, 
    			'total' => amount}

  		@result = Queries.put("sii/boleta", authorization=false, body)
  		return JSON.parse @result.body
  	end

end