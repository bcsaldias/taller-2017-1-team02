#include HTTParty
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  api! "obtener_precios: Retorna una lista de los productos, materias primas y precios disponibles
      para venta por la empresa."
  meta :product => {sku:0, name: 'producto0', price: 20, stock: 100}
  error 404, "Lista de precios no disponible"

  def available
    json_response(Product.catalogue)
  end

  # GET /products
  def index
    @products = Product.all

    render json: @products
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  def buy
    # sku = Product.first.sku
    sku = "2" #"Huevo"
    p = Product.find(sku)
    puts "Producto: #{p}"


    quantity = 100
    comprar_materia_prima(sku, quantity)

    # puts "Here is the sku:"
    # puts sku
    # # product = Product.first#find(sku: sku)
    # product = Product.find(sku)
    # puts product.description
    #
    # # puts product.description
    # suppliers = product.suppliers
    # puts suppliers
    #
    # # proveedor_precio = [] # Lista con precio: proveedor
    # # get_best_supplier(proveedor_precio, producto)


    # header = {	'Content-Type' => 'application/json'}
    # response = HTTParty.get("http://localhost:3000/products", headers: header, query: {})
    # hash_response = JSON.parse(response.body)
    # api_product = hash_response.find {|prod| prod['sku'] == sku}#['price']
    # puts "This is the product:"
    # puts api_product
    # puts "This is the price:"
    # puts api_product['price']





    json_response(Product.catalogue)

  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_params
      params.require(:product).permit(:sku, :description, :type, :production_unit_cost, :price, :min_production_batch, :expected_production_time, :supplier_id)
    end
end
