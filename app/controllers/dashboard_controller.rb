class DashboardController < ActionController::Base
  require 'json'
  def index
    @purchase_orders = PurchaseOrder.all#.where(owner: true)
    @products = Product.all.where(owner: true)
    @warehouses = Production.get_warehouses
  end
end
