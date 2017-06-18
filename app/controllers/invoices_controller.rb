class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :update, :destroy]


  require 'json'



  api! "enviar_factura: Crea una notificación de habernos emitido una factura.
      Debe tener el id de la factura y la cuenta del banco."
  param :bank_account, String, :required => true, :desc => "Identificador de la cuenta destino de pago."

  error 400, "Formato de  Body incorrecto"
  ##error 400, "Factura no corresponde a proveedor" NO CORRESPONDE
  error 400 ,"Factura no nos corresponde a nosotros"
  error 400, "Debe proporcionar una cuenta bancaria para recibir el pago"
  error 403, "Ya se envió esta factura"
  error 400, "Factura no encontrada"

  # PUT /invoices/:id
  def enviar_factura
      #begin
        @body = JSON.parse request.body.read
        @keys = @body.keys
        if not @keys.include?("bank_account")
          json_response({ :error => "Debe proporcionar una cuenta bancaria" }, 400)
        elsif Invoice.where(id_cloud: params[:id]).count != 0
          json_response({ :error => "Ya se envió esta factura" }, 403)
        else
          invoice = Invoices.obtener_factura(params[:id])
          bank_account = @body["bank_account"]
          if not invoice.keys.include?("error")
            oc = PurchaseOrder.where(id_cloud: invoice['oc']).first
            tid = Rails.configuration.environment_ids['team_id']
            if invoice['cliente'] == tid
              @invoice = Invoice.create!(id_cloud: params[:id],
                                                  cliente: invoice['cliente'],
                                                  proveedor: invoice['proveedor'],
                                                  bruto:  invoice['bruto'],
                                                  iva: invoice['iva'],
                                                  oc_id_cloud: invoice['oc'],
                                                  status: 0,
                                                  bank_account: bank_account,
                                                  purchase_order_id: oc.id)
              puts "Factura recibida: #{params[:id]}"
              begin
                json_response(
                {
                  id_invoice: params[:id],
                  bank_account: params[:bank_account]
                  }, 200)
                  puts "Retorno status 200 (factura recibida)"
              rescue
                puts "error"
              ensure
                  puts "evaluando factura recibida", params[:id]

                  if @invoice.evaluar_si_aceptar
                    puts 'Aceptando factura'
                    ret = Invoices.enviar_confirmacion_factura(@invoice.id_cloud)
                    puts "Aceptacion factura, cliente retorna: #{ret}"
                  else
                    puts 'Rechazando factura'
                    ret = Invoices.enviar_rechazo_factura(@invoice.id_cloud, @invoice.cause)
                    puts "Factura rechazo cliente retorna: #{ret}"
                  end


              end

            else
              json_response({ :error => "Factura no nos corresponde a nosotros"}, 400)
            end
          else
            json_response({ :error => "Factura no encontrada" }, 400)
          end
        end
      # rescue
      #   json_response({ :error => "Formato de Body incorrecto" }, 400)
      # end
  end




  api! "enviar_confirmacion_factura: Crea una notificación de que no se rechazará la factura enviada.
      Debe tener el id de la factura"
  error 403, "Ya se rechazó la factura"
  error 403, "Ya se pagó la factura"
  error 403, "Ya se anuló la factura"
  error 404, "Factura no existente"
  error 500, "El envío ha fallado"

  # PATCH /invoices/:id/accepted
  def enviar_confirmacion_factura
    invoice = Invoice.where(id_cloud: params[:id]).first
    begin
      if invoice
        if invoice.status == "rechazada"
          json_response ({ error: "Ya se rechazó la factura" }), 403
        elsif invoice.status == "pagada"
          json_response ({ error: "Ya se pagó la factura" }), 403
        elsif invoice.status == "anulada"
          json_response ({ error: "Ya se anuló la factura" }), 403
        else
          invoice.status = 4
          invoice.save!

          # AGREGAR A COLA DE DESPACHO
          count_our_order = PurchaseOrder.where(id_cloud: invoice.oc_id_cloud)
          if count_our_order.count > 0
            our_order = count_our_order.first
            our_order.queued = true
            our_order.save!
          end

          json_response(
              {
                id_invoice: params[:id],
                status: invoice.status
              }, 200)
        end
      else
          json_response(
              { error: 'Factura no existente'
              }, 404)
      end
    rescue
      json_response({ :error => "Revise proveedor de factura u otros" }, 400)
    end
  end


  api! "enviar_rechazo_factura: Crea una notificación de que se rechaza la factura enviada.
      Debe tener el id de la factura."
  #param :cause, String, :required => true, :desc => "Causa de rechazo."
  error 400, "Formato de  Body incorrecto"
  error 400, "Debe entregar una razón de rechazo"
  error 400, "Razón debe ser distinta de nula"
  error 403, "Ya se confirmó/rechazó la factura"
  error 403, "Ya se anuló la factura"
  error 404, "Factura no existente"
  error 500, "El envío ha fallado"

  # PATCH /invoices/:id/rejected
  def enviar_rechazo_factura
    invoice = Invoice.where(id_cloud: params[:id]).first
    begin
      if invoice
        @body = JSON.parse request.body.read
        @keys = @body.keys

        if not @keys.include?("cause")
          json_response ({ error: "Debe entregar una razón de rechazo" }), 400
        elsif params[:cause].length == 0
          json_response ({ error: "La razón debe ser distinta de nula" }), 400
        elsif invoice.status == "aceptada" or invoice.status == "rechazada"
            json_response ({ error: "Ya se confirmó/rechazó la factura" }), 403
        elsif invoice.status == "anulada"
          json_response ({ error: "Ya se anuló la factura" }), 403
        elsif invoice.status == "pagada"
          json_response ({ error: "Ya se pagó la factura" }), 403
        else
          invoice.status = 3
          invoice.cause = params[:cause]
          invoice.save
          json_response(
                  {
                    id_invoice: params[:id],
                    status: invoice.status
                  }, 200)
        end
      else
        json_response(
                { error: 'Factura no existente'
                }, 404)
      end
    rescue
          json_response({ :error => "Formato de Body incorrecto" }, 400)
    end

  end



  ## COKE
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

    #begin
      @body = JSON.parse request.body.read
      @keys = @body.keys
      if not @keys.include?("id_transaction")
        json_response ({ error: "Debe entregar el id de una transacción"}), 400
      else
        invoice_id = params[:id]
        q_invoice = Invoice.where(id_cloud: invoice_id)#.first
        invoice = nil
	if q_invoice.count > 0
	  invoice = q_invoice.first
	else
   	  json_response ({ error: "Factura no existe"}), 404
	  return
	end

	# purchase_order = PurchaseOrder.where(id_cloud: invoice.oc_id_cloud).first
        #llamar la transaccion a la nube
        transaction_id = @body['id_transaction']
        puts "Trx_id: #{transaction_id}"
        transaction = Bank.get_transaction(transaction_id)
        puts "Bank_transaction: #{transaction}"

        #revisar si la transaccion existe
        if transaction.code!=200 && transaction.code!=201
          json_response ({ error: "Transaccion no existente"}), 404
        else

          #revisar que no exista localmente
          our_transaction = Transaction.find_by(id_cloud: @body['id_transaction'])
          if our_transaction == nil
            #comparo valor desde purchase order y transferencia
            total_a_pagar = invoice.bruto + invoice.iva
            total_pagado = transaction[0]['monto'].to_i
            if total_pagado == total_a_pagar
              #guardar transaccion localmente
              #se guarda como una transaccion exitosa
              status = true
            else
              #se guarda como una transaccion NO exitosa
              status = false
            end
            transaction = transaction[0]
            puts "Creando transaccion localmente"
            @transaction = Transaction.create!(id_cloud: transaction['_id'], origen: transaction['origen'],
                                          destino: transaction['destino'], monto: transaction['monto'].to_i,
                                          owner: false, state: status)
            puts "Creada: #{@transaction}"
            # json_response({status: "success"}, 204)
            json_response({ :status => "Exito"}, 201)
            # json_response(@transaction, 204)
            #si ya estaba en mi tabla local
          else
            puts "Ya se habia enviado confirmacion de pago"
            json_response({ :error => "Ya se envió confirmación de pago"}, 403)
          end
        end
      end

    #rescue
    #      json_response({ :error => "Formato de Body incorrecto" }, 400)
    #end

  end


  api! "notificar_orden_despachada: Notificar para cambiar de estado de una factura.
      Debe tener el id de la factura."
  error 403, "Ya se notificó entrega de esta factura"
  error 404, "Factura no encontrada"

  # PATCH /invoices/:id/delivered
  def notificar_orden_despachada
      invoice_id = params[:id]

      invoice = Invoices.obtener_factura(invoice_id)

      if not invoice.keys.include?("error")

        our_invoice = Invoice.where(id_cloud: invoice_id).first
        oc_id_cloud = our_invoice.oc_id_cloud
        our_purchase_order = PurchaseOrder.where(id_cloud: oc_id_cloud).first

        if our_invoice.status == 5
          json_response({ :error => "Ya se notificó entrega de esta factura" }, 403)

        elsif our_purchase_order.state != 'aceptada'
          json_response({ :error => "OC asociada no aceptada" }, 400)

        else

            purchase_order = Sales.get_purchase_order(oc_id_cloud)
            q_faltante = purchase_order["cantidad"].to_i - purchase_order["cantidadDespachada"].to_i

            our_purchase_order.quantity_done = purchase_order["cantidadDespachada"].to_i
            our_purchase_order.save!


            if q_faltante > 0
              json_response(
              {
                  :error => "No se ha despachado completamente" ,
              }, 400)

            else
              our_invoice.status = 5
              our_invoice.save!
              our_purchase_order.state = 3
              our_purchase_order.save!

              json_response(
                  {
                    id_invoice: params[:id],
              }, 200)

            end



        end

      else
        json_response({ :error => "Factura no encontrada" }, 400)

      end



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
