module Spree
  include HTTParty
  require 'uri'

  # This is somewhat contrary to standard REST convention since there is not
  # actually a Checkout object. There's enough distinct logic specific to
  # checkout which has nothing to do with updating an order that this approach
  # is waranted.
  class CheckoutController < Spree::StoreController
    before_action :load_order_with_lock
    before_action :ensure_valid_state_lock_version, only: [:update]
    before_action :set_state_if_present

    before_action :ensure_order_not_completed
    before_action :ensure_checkout_allowed
    before_action :ensure_sufficient_stock_lines
    before_action :ensure_valid_state

    before_action :associate_user
    before_action :check_authorization

    before_action :setup_for_current_state
    before_action :add_store_credit_payments, only: [:update]

    helper 'spree/orders'

    rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error

    def create_voucher(order)
      _id = order.number
      _user_id = order.user_id
      _address = order.ship_address.address1
      _amount = order.total.to_i
      invoice = Invoices.crear_boleta(_id, _user_id, _amount, _address)
    end

    def escape_uri(string)
      CGI::escape(string)
    end

    def paid
      #FIXME -> this should be more secure!!
      our_env_path = Rails.configuration.environment_ids['our_env_path']
      current_bp = our_env_path+'ecommerce/'
      #current_bp = 'http://localhost:3000/ecommerce/'

      delivered = false
      all_ok = false

      #ir a buscar transacción y despachar
      voucher = Voucher.where(id_cloud: params[:id]).first
      cliente = voucher.client
      monto_total = voucher.bruto + voucher.iva
      
      transactions_query = Bank.get_our_card
      transactions =  transactions_query['data']
      total = transactions_query['total'].to_i
      
      transactions.each do |trx|
        temp_trx = Transaction.where(id_cloud: trx['_id']).first

        if temp_trx == nil
          q0 = (trx['origen'] == cliente)
          q1 = (trx['monto'].to_i == monto_total.to_i)
          if true and q1
            Transaction.create!(id_cloud: trx['_id'], 
                                origen: trx['origen'],
                                destino: trx['destino'], 
                                monto: trx['monto'].to_i,
                                owner: false, state: true)
            all_ok = true
          end
        end
      end

      #Bank.transfer
      #me manda el id de la transferencia?
      if all_ok
        @order.next
        @order.completed?
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
      end

      begin
        redirect_to(current_bp+'orders/'+@order.number.to_s)
      rescue
        puts "ERROR"
      ensure
        #delivered = 
	      Production.save_order_for_delivering(voucher)
        #if delivered
        #  voucher.status = 'despachada'
        #  voucher.save!
        #end
        puts "DESPACHENLA!"
      end


      #if not delivered
      #  puts "not delivered"
        #puts "ERRORRRR"
        #puts "ERRORRRR"
        #redirect_to(current_bp+'checkout/payment')
      #else
      #  puts "EXITO"
      #  puts "EXITO"
      #  voucher.status = 'despachada'
      #  voucher.save!
      #end
      #  redirect_to(current_bp+'orders/'+@order.number.to_s)
    end

    def go_to_paid(order, voucher)
      _id = voucher['_id'].to_s
      _base_path = Rails.configuration.environment_ids['environment_path']

      our_env_path = Rails.configuration.environment_ids['our_env_path']
      current_bp = our_env_path+'ecommerce/'
      #current_bp = 'http://localhost:3000/ecommerce/'

      @URL_OK = escape_uri(current_bp+"order/paid/"+_id)
      @URL_FAIL = escape_uri(current_bp+'checkout/payment')
      
      _post_base = "web/pagoenlinea?callbackUrl="
      url = _base_path+ _post_base + @URL_OK + "&cancelUrl="+@URL_FAIL+"&boletaId="+_id
      redirect_to url
    end

    # Updates the order and advances to the next state (when possible.)
    def update
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        
        if @order.state == 'payment'
          voucher = self.create_voucher(@order)
          self.go_to_paid(@order, voucher)
        else

          unless @order.next
            flash[:error] = @order.errors.full_messages.join("\n")
            redirect_to(checkout_state_path(@order.state)) && return
          end

          if not @order.completed?
            redirect_to checkout_state_path(@order.state)
          end
        end

      else
        render :edit
      end
    end

    private

    def unknown_state?
      (params[:state] && !@order.has_checkout_step?(params[:state])) ||
        (!params[:state] && !@order.has_checkout_step?(@order.state))
    end

    def insufficient_payment?
      params[:state] == "confirm" &&
        @order.payment_required? &&
        @order.payments.valid.sum(:amount) != @order.total
    end

    def correct_state
      if unknown_state?
        @order.checkout_steps.first
      elsif insufficient_payment?
        'payment'
      else
        @order.state
      end
    end

    def ensure_valid_state
      if @order.state != correct_state && !skip_state_validation?
        flash.keep
        @order.update_column(:state, correct_state)
        redirect_to checkout_state_path(@order.state)
      end
    end

    # Should be overriden if you have areas of your checkout that don't match
    # up to a step within checkout_steps, such as a registration step
    def skip_state_validation?
      false
    end

    def load_order_with_lock
      @order = current_order(lock: true)
      redirect_to(spree.cart_path) && return unless @order
    end

    def ensure_valid_state_lock_version
      if params[:order] && params[:order][:state_lock_version]
        @order.with_lock do
          unless @order.state_lock_version == params[:order].delete(:state_lock_version).to_i
            flash[:error] = Spree.t(:order_already_updated)
            redirect_to(checkout_state_path(@order.state)) && return
          end
          @order.increment!(:state_lock_version)
        end
      end
    end

    def set_state_if_present
      if params[:state]
        if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
          redirect_to checkout_state_path(@order.state)
        end
        @order.state = params[:state]
      end
    end

    def ensure_checkout_allowed
      unless @order.checkout_allowed?
        redirect_to spree.cart_path
      end
    end

    def ensure_order_not_completed
      redirect_to spree.cart_path if @order.completed?
    end

    def ensure_sufficient_stock_lines
      if @order.insufficient_stock_lines.present?
        flash[:error] = Spree.t(:inventory_error_flash_for_insufficient_quantity)
        redirect_to spree.cart_path
      end
    end

    # Provides a route to redirect after order completion
    def completion_route(custom_params = nil)
      spree.order_path(@order, custom_params)
    end

    def setup_for_current_state
      method_name = :"before_#{@order.state}"
      send(method_name) if respond_to?(method_name, true)
    end

    def before_address
      # if the user has a default address, a callback takes care of setting
      # that; but if he doesn't, we need to build an empty one here
      @order.bill_address ||= Address.build_default
      @order.ship_address ||= Address.build_default if @order.checkout_steps.include?('delivery')
    end

    def before_delivery
      return if params[:order].present?

      packages = @order.shipments.map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    end

    def before_payment
      if @order.checkout_steps.include? "delivery"
        packages = @order.shipments.map(&:to_package)
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
        @differentiator.missing.each do |variant, quantity|
          @order.contents.remove(variant, quantity)
        end
      end

      if try_spree_current_user && try_spree_current_user.respond_to?(:payment_sources)
        @payment_sources = try_spree_current_user.payment_sources
      end
    end

    def add_store_credit_payments
      if params.has_key?(:apply_store_credit)
        @order.add_store_credit_payments

        # Remove other payment method parameters.
        params[:order].delete(:payments_attributes)
        params[:order].delete(:existing_card)
        params.delete(:payment_source)

        # Return to the Payments page if additional payment is needed.
        if @order.payments.valid.sum(:amount) < @order.total
          redirect_to checkout_state_path(@order.state) and return
        end
      end
    end

    def rescue_from_spree_gateway_error(exception)
      flash.now[:error] = Spree.t(:spree_gateway_error_flash_for_checkout)
      @order.errors.add(:base, exception.message)
      render :edit
    end

    def check_authorization
      authorize!(:edit, current_order, cookies.signed[:guest_token])
    end
  end
end
