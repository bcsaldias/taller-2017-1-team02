module Factory
	include Queries
	require 'json'
  	
	def self.get_account
	    auth = Queries.generate_authorization
        @result = Queries.get("bodega/fabrica/getCuenta", 
	    						authorization=auth)
	    return JSON.parse @result.body
	end

	def self.fabricate_without_paying(sku, cantidad)
	    auth = Queries.generate_authorization(_method = 'PUT', 
	                    params = [sku, cantidad])
	    body = {'sku' => sku , 'cantidad' => cantidad}
	    
	    @result = Queries.put('bodega/fabrica/fabricarSinPago', 
	              authorization=auth,
	              body=body)
	    puts @result
	    return JSON.parse @result.body
	end

end