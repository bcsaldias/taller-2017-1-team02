module ApplicationHelper
	def sortable(column, title = nil)
	  title ||= column.titleize
	  direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
	  link_to title, {:sort => column, :direction => direction}
	end
end 


#oc = PurchaseOrder.create!(id_cloud: "6987608", state: 0, product_sku: "76", payment_method: "contra_factura", quantity: 35, quantity_done: 20, owner: true, group_number: 7, team_id_cloud: "876ugihgc")

