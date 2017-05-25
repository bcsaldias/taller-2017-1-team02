module Payment
	include Queries
  	require 'json'

  	def self.portal(boletaId)

      @URL_OK = ""
      @URL_FAIL = ""

    	params = {'callbackUrl' => @URL_OK, 
    			'cancelUrl' => @URL_FAIL, 
    			'boletaId' => boletaId}

  		@result = Queries.get("web/pagoenlinea", authorization=false, params)
  		@body = @result.body #JSON.parse 

  		return @result
  	end

end

