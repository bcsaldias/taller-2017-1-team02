class DashboardController < ActionController::Base
  require 'json'
  def index
    @production_orders = ProductionOrder.all#.where(owner: true)
    @products = Product.our_products
    @warehouses = Production.get_warehouses
    @vouchers = Voucher.all
  end
end
