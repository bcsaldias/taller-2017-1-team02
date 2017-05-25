module Payment
	include Queries
  	require 'json'

  	def self.portal(boletaId)

      URL_OK = ""
      URL_FAIL = ""


    	params = {'callbackUrl' => URL_OK, 
    			'cancelUrl' => URL_FAIL, 
    			'boletaId' => boletaId}


  		@result = Queries.get("/web/pagoenlinea", authorization=false, params)
  		@body = JSON.parse @result.body

  		return @result.code
  	end

end

