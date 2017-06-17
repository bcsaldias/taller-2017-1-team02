module FtpOrders
	
	def self.save_fpt_order(order_id)
      order = Sales.get_purchase_order(order_id)
      @purchase_order = PurchaseOrder.create!(id_cloud: order['_id'],
                                          state: order["estado"],
                                          product_sku: order['sku'],
                                          id_store_reception:  'distribuidor',
                                          quantity: order["cantidad"],
                                          quantity_done: 0,
                                          deadline: order['fechaEntrega'],
                                          unit_price: order['precioUnitario'],
                                          group_number: -1, #means sftp
                                          team_id_cloud: order['cliente']
                                          )
	end

	def self.revisar_ftp_order(order_id)
		if PurchaseOrder.where(id_cloud: order_id).count == 0
			self.save_fpt_order(order_id)
	    end

		if Invoice.where(oc_id_cloud: order_id).count == 0
  			Invoices.emitir_factura(order_id)
	    end	    

	end

	def self.check_orders

		host = Rails.configuration.environment_ids['ftp_host']
		user = Rails.configuration.environment_ids['ftp_user']
		password = Rails.configuration.environment_ids['ftp_pass']

		Net::SFTP.start(host, user, :password => password) do |sftp|
		  base = "./pedidos/"
		  sftp.dir.foreach(base) do |entry|
		  	if not ['.','..','.cache'].include?(entry.name)
		    	sftp.file.open(base+entry.name, "r") do |f|
				   while !f.eof?
				   	current_line = f.gets
				    if current_line.include?('id')
				    	data = data = Hash.from_xml(current_line)
				    	self.revisar_ftp_order(data['id'])
				    end
				  end
				end
		  	end
		  end
		end
		return true
	end

end
