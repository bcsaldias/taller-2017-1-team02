class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  api! "obtener_precios: Retorna una lista de los productos, materias primas y precios disponibles
      para venta por la empresa."
  meta :product => {sku:'J20000022', name: 'producto0', price: 20, stock: 100}
  error 404, "Lista de precios no disponible"

  def available
    
    #string = [{sku:'J20000022', name: 'producto0', price: 20, stock: 100},
    #          {sku: 'J10999972', name: 'producto1', price: 30, stock: 200}]
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
