
module Sales
	include Queries

	def self.get_purchase_order(purchase_order_id)
		@result = Queries.get("oc/obtener",
						  purchase_order_id)
		return @result.body
	end

end
