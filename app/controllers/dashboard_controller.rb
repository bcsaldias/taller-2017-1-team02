class DashboardController < ActionController::Base
  require 'json'
  def index
    @production_orders = ProductionOrder.all#.where(owner: true)
    @products = Product.our_products
    @warehouses = Production.get_warehouses
    @vouchers = Voucher.all
    @leche = Product.leche

    # j: Calculamos el stock por producto y por bodega
    warehouses_id = Warehouses.get_warehouses_id
    @stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
    @stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    @stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
    @stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    @stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
    @product_ids = ["7", "2", "6", "8", "14", "20", "26", "39", "40", "41", "49"]
    @stock_by_product = {}
    @product_ids.each do |p_id|
      @stock_by_product[p_id] = 0
    end
    (@stock_pulmon + @stock_recepcion + @stock_pregeneral + @stock_general + @stock_despacho).each do |stock|
      @stock_by_product[stock["_id"]] += stock["total"]
    end

  end
end
