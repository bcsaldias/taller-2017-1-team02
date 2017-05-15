class ApplicationController < ActionController::API
	include Response
    include ExceptionHandler
    include Production
    include Queries
		include RawMaterial
		include Tiempo
end
