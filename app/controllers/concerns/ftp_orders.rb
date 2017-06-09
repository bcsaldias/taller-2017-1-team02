module FtpOrders

	def save_fpt_order(order_id)
      order = Sales.get_purchase_order(order_id)
      @purchase_order = PurchaseOrder.create!(id_cloud: order['_id'],
                                          state: 0,
                                          product_sku: order['sku'],
                                          payment_method: params[:payment_method],
                                          id_store_reception:  params[:id_store_reception],
                                          quantity: order["cantidad"],
                                          quantity_done: 0,
                                          deadline: order['fechaEntrega'],
                                          unit_price: order['precioUnitario'],
                                          group_number: -1, #means sftp
                                          team_id_cloud: order['cliente']
                                          )
	end

	def revisar_ftp_order(order_id)
		if PurchaseOrder.where(id_cloud: order_id).count == 0
			save_fpt_order(order_id)
		end
	end

	def check_orders

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
				    	revisar_ftp_order(data['id'])
				    end
				  end
				end
		  	end
		  end
		  json_response({ret:  true })
		end
	end

end