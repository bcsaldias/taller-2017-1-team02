class ApplicationController < ActionController::Base
	include Response
    include ExceptionHandler
    include Production
    include Queries
		include RawMaterial
end
