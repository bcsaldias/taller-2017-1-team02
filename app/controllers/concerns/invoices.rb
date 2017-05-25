module Invoices
	include Queries
  	require 'json'

  	def self.crear_boleta(private_client_id, amount)
      origin_group_id = Rails.configuration.environment_ids['team_id']
    	body = {'proveedor' => origin_group_id, 
    			'cliente' => private_client_id, 
    			'total' => amount}

  		@result = Queries.put("sii/boleta", authorization=false, body)
  		@body = JSON.parse @result.body

  		if @result.code == 200 or @result.code == 201
  			Voucher.create!(id_cloud: @body['_id'],
  							client: @body['cliente'],
  							bruto: @body['bruto'].to_i,
  							iva: @body['iva'].to_i,
  							oc_id_cloud: @body['oc'],
  							status: @body['estado']
  				)
  		end

  		return @body#.code
  	end

end

