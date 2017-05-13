
module Factory
	include Queries
  	
	def self.get_account
	    auth = Queries.generate_authorization
        @result = Queries.get("bodega/fabrica/getCuenta", 
	    						authorization=auth)
	    return @result.body
	end

	def self.fabricate_without_paying(sku, cantidad)

	    auth = Queries.generate_authorization(_method = 'PUT', 
	                    params = [sku, cantidad])

	    body = {'sku' => sku , 'cantidad' => cantidad}
	    
	    @result = Queries.put('bodega/fabrica/fabricarSinPago', 
	              authorization=auth,
	              body=body)

	    return @result.body
	end



end