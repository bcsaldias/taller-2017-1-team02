module Promotions
  
  def self.create(codigo, inicio, fin, sku, precio, publicar)

    producto = Product.find(sku)
    product_name = producto.description 
    final_discount = producto.price - precio
    final_discount = [0, final_discount].max

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

    discount = Discount.create!(
	      sku: sku,
	      precio: precio,
	      inicio: inicio,
	      fin: fin,
	      codigo: codigo,
	      publicar: publicar,
	      activation_count: 0,
	      spree_adj_id: ajuste.id
    	)

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
    ajuste = Spree::Promotion::Actions::CreateItemAdjustments.find(discount.spree_adj_id)
    
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

end
