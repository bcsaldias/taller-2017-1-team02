class VouchersController < ApplicationController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy]

  # GET /vouchers
  def index
    @vouchers = Voucher.all
  end

  # GET /vouchers/1
  def show
  end

  # GET /vouchers/new
  def new
    @voucher = Voucher.new
  end

  # GET /vouchers/1/edit
  def edit
  end

  # POST /vouchers
  def create
    @voucher = Voucher.new(voucher_params)

    if @voucher.save
      redirect_to @voucher, notice: 'Voucher was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /vouchers/1
  def update
    if @voucher.update(voucher_params)
      redirect_to @voucher, notice: 'Voucher was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /vouchers/1
  def destroy
    @voucher.destroy
    redirect_to vouchers_url, notice: 'Voucher was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voucher
      @voucher = Voucher.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def voucher_params
      params.require(:voucher).permit(:id_cloud, :client, :bruto, :iva, :oc_id_cloud, :status)
    end
end
