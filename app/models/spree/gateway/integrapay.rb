module Spree
  
  class Gateway::Integrapay < Gateway
    preference :api_environment,    :string, default: 'sandbox'
    preference :api_key,            :string
    preference :api_sercret,        :string
    preference :api_payment_method, :string

    STATE = 'integrapay'

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def provider_class
      IntegraPay::Api
    end

    def actions
      %w{capture}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      puts "MILAAAN"
      payment.pending? || payment.checkout?
    end

    def capture(money_cents, response_code, gateway_options)
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
      puts "GERARD"
    end

    def auto_capture?
      false
    end

    def method_type
      'integrapay'
    end
  end

end