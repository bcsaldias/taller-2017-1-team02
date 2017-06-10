module ApplicationHelper

	def sortable(column, title = nil, nombre, defecto)
		title ||= column.titleize
		direction = column == sort_column(nombre, defecto) && sort_direction == "asc" ? "desc" : "asc"
		link_to title, {:sort => column, :direction => direction}
	end

	def seg2dhms(secs)
		time = secs.round
		sec = time % 60
		time /= 60
		mins = time % 60
		time /= 60
		hrs = time % 24
		time /= 24
		days = time
		days.to_s + "d " + hrs.to_s + "hrs"
		#[days, hrs, mins, sec]
	end

end 


#oc = PurchaseOrder.create!(id_cloud: "6987608", state: 0, product_sku: "76", payment_method: "contra_factura", quantity: 35, quantity_done: 20, owner: true, group_number: 7, team_id_cloud: "876ugihgc")

