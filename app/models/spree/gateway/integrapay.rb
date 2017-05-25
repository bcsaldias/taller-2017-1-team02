module Spree
  
  class Gateway::Integrapay < Gateway

    STATE = 'integrapay'

    def payment_profiles_supported?
      false
    end

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    def method_type
      'integrapay'
    end

    def purchase(amount, transaction_details, options = {})
      puts "SHAKIRAAAAAAAAAAAAAAAAAA"
      ActiveMerchant::Billing::Response.new(true, 'success', {}, {})
    end

  end

end