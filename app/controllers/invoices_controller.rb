class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :update, :destroy]


  require 'json'

  api! "enviar_confirmacion_factura: Crea una notificación de que no se rechazará la factura enviada.
      Debe tener el id de la factura"
  error 403, "Ya se confirmó/rechazó la factura"
  error 404, "Factura no existente"
  error 500, "El envío ha fallado"

  # PATCH /invoices/:id/accepted
  def enviar_confirmacion_factura
    json_response "", 204
  end

  api! "enviar_rechazo_factura: Crea una notificación de que se rechaza la factura enviada.
      Debe tener el id de la factura."
  #param :cause, String, :required => true, :desc => "Causa de rechazo."
  error 400, "Formato de  Body incorrecto"
  error 400, "Debe entregar una razón de rechazo"
  error 400, "Razón debe ser distinta de nula"
  error 403, "Ya se confirmó/rechazó la factura"
  error 404, "Factura no existente"
  error 500, "El envío ha fallado"

  # PATCH /invoices/:id/rejected
  def enviar_rechazo_factura

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys

      if not @keys.include?("cause")
        json_response ({ error: "Debe entregar una razón de rechazo" }), 400
      elsif params[:cause].length == 0
        json_response ({ error: "La razón debe ser distinta de nula" }), 400
      else
        json_response "", 204
      end

    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  api! "enviar_confirmacion_pago: Crea una notificación de que se pagó la factura.
      Debe tener el id de la factura."
  param :id_transaction, String, :required => true, :desc => "Identificador transacción bancaria."
  error 400, "Formato de  Body incorrecto"
  error 400, "Debe entregar el id de una transacción"
  error 403, "Ya se envió confirmación de pago"
  error 404, "Factura no existente"
  error 404, "Transacción no existente"
  error 500, "El envío ha fallado"
  # PATCH /invoices/:id/paid
  def enviar_confirmacion_pago

    begin
      @body = JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_transaction")
        json_response ({ error: "Debe entregar el id de una transacción"}), 400
      else
        json_response "", 204
      end

    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end

  api! "enviar_factura: Crea una notificación de habernos emitido una factura.
      Debe tener el id de la factura y la cuenta del banco."
  param :bank_account, String, :required => true, :desc => "Identificador de la cuenta destino de pago."

  error 400, "Formato de  Body incorrecto"
  error 400, "Factura no corresponde a proveedor"
  error 400 ,"Factura no nos corresponde a nosotros"
  error 400, "Debe proporcionar una cuenta bancaria para recibir el pago"
  error 403, "Ya se envió esta factura"
  error 400, "Factura no encontrada"

  # PUT /invoices/:id
  def enviar_factura

      begin

        @body =  JSON.parse request.body.read
        @keys = @body.keys

        if not @keys.include?("bank_account")
            json_response({ :error => "Debe proporcionar una cuenta bancaria" }, 400)

        else
            json_response(
            {
              id_invoice: params[:id],
              bank_account: params[:bank_account]
            }, 200)
        end

      rescue
            json_response({ :error => "Formato de Body incorrecto" }, 400)

      end

  end

  api! "notificar_orden_despachada: Notificar para cambiar de estado de una factura.
      Debe tener el id de la factura."
  error 403, "Ya se notificó entrega de esta factura"
  error 404, "Factura no encontrada"
  # PATCH /invoices/:id
  def notificar_orden_despachada
      json_response('Notificación hecha',204)
  end



  # GET /invoices
  def index
    @invoices = Invoice.all

    render json: @invoices
  end

  # GET /invoices/1
  def show
    render json: @invoice
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      render json: @invoice, status: :created, location: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1
  def update
    if @invoice.update(invoice_params)
      render json: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def invoice_params
      params.require(:invoice).permit(:id_cloud, :state, :purchase_order_id)
    end
end
