class ApplicationController < ActionController::Base
	#protect_from_forgery with: :exception
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
	include FtpOrders

	private
	def not_authenticated
	  redirect_to login_path, alert: "Please login first"
	end
	
end
