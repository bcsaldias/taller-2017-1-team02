class ApplicationController < ActionController::Base
	include Response
    include ExceptionHandler
    include Production
    include Queries
	include RawMaterial
	include Tiempo
	include Warehouses
	include Factory
	include Invoices
	include Sales

	private
	def not_authenticated
	  redirect_to login_path, alert: "Please login first"
	end
	
end
