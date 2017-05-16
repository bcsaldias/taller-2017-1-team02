class ApplicationController < ActionController::Base
	include Response
    include ExceptionHandler
    include Production
    include Queries
	include RawMaterial
	include Tiempo

	private
	def not_authenticated
	  redirect_to login_path, alert: "Please login first"
	end
	
end
