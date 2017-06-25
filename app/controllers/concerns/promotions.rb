module Promotions
  
  def self.get_next_promotion

    uri = Rails.configuration.environment_ids['queue']
    b = Bunny.new uri
    b.start
    ch = b.create_channel
    q = ch.queue('ofertas', auto_delete: true)
    delivery, headers, msg = q.pop
    puts msg
    b.stop
    return JSON.parse msg
    
  end


  def self.get_ofertas

        promotion = Promotions.get_next_promotion() 
        prom = nil
        puts "Starging while Promotions"
        many = 0
        first_p = promotion
        while promotion != nil
            puts promotion
            puts promotion["sku"]
            our_product = Product.find(promotion["sku"])
            if our_product != nil
              our_product = our_product.owner
            end
            puts our_product
            if our_product
              many +=1
                prom = Promotions.create(promotion["codigo"], 
                                        Time.at(promotion["inicio"].to_f /  1000), 
                                        Time.at(promotion["fin"].to_f / 1000), 
                                        promotion["sku"], promotion["precio"], promotion["publicar"])
            end
            promotion = Promotions.get_next_promotion()
        end

        Discount.all.each do |d|
          Promotions.update(d.codigo)
        end

        puts "NUEVAS"
        puts many
        return first_p

    end


  def self.create(codigo, inicio, fin, sku, precio, publicar)

    producto = Product.find(sku)
    product_name = producto.description 
    final_discount = producto.price - precio
    final_discount = [0, final_discount].max

    discount = Discount.create!(
	      sku: sku,
	      precio: precio,
	      inicio: inicio,
	      fin: fin,
	      codigo: codigo,
	      publicar: publicar,
	      activation_count: 0)

    promotion = Spree::Promotion.create!(
      description: codigo, 
      expires_at: fin, 
      starts_at: inicio, 
      name: codigo, 
      type: nil, 
      usage_limit: 1000000000, 
      match_policy: "all", 
      code: codigo, 
      advertise: true, 
      path: nil,
      promotion_category_id: nil)

    rule = Spree::Promotion::Rules::Product.create!(
      promotion_id: promotion.id, 
      user_id: nil, 
      product_group_id: nil, 
      type: "Spree::Promotion::Rules::Product",
      code: nil, 
      preferences: {match_policy: "any"})

    product = Spree::Product.where(name: product_name).first
    rule.products << product
    rule.save!

    ajuste = Spree::Promotion::Actions::CreateItemAdjustments.create!(
      promotion_id: promotion.id,
      position: nil,
      type: "Spree::Promotion::Actions::CreateItemAdjustments",
      deleted_at: nil)

	discount.spree_adj_id = ajuste.id
	discount.save!

    calculator = Spree::Calculator.create!(
        type: "Spree::Calculator::FlexiRate", 
        calculable_type: "Spree::PromotionAction", 
        calculable_id: 4, 
        preferences: {currency: "USD", 
        first_item: final_discount, 
        additional_item: final_discount, 
        max_items: 10000000000})

    ajuste.calculator = calculator
    ajuste.save!

    return discount

  end

  def self.update(codigo)

    discount = Discount.where(codigo: codigo).first
    ajuste = Spree::Promotion::Actions::CreateItemAdjustments.where(id: discount.spree_adj_id)
    
    if ajuste.count > 0
      ajuste = ajuste.first
      product = Product.find(discount.sku)
      precio_final = discount.precio
      final_discount = product.price - precio_final
      final_discount = [0, final_discount].max

      calculator = ajuste.calculator
      puts calculator
      calculator.preferences = {currency: "USD", 
          first_item: final_discount, 
          additional_item: final_discount, 
          max_items: 10000000000}
      calculator.save!

      return discount
    end
    return nil

  end

end
