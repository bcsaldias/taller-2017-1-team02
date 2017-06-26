module Promotions

  def self.get_beautty_message(promotion)

    product = Product.find(promotion.sku)
    inicio = promotion.inicio.strftime("%d/%b at %I:%M%p")
    fin = promotion.fin.strftime("%d/%b at %I:%M%p")
    env_path = Rails.configuration.environment_ids['our_env_path']
    return "Usa el código '#{promotion.codigo}' para poder comprar #{product.description} a solo $#{promotion.precio}. 
            Válido entre #{inicio} y #{fin}. ¡Visítanos en "+env_path+"ecommerce!"

  end

  def self.get_short_beautty_message(promotion)

    product = Product.find(promotion.sku)
    inicio = promotion.inicio.strftime("%d/%b at %I:%M%p")
    fin = promotion.fin.strftime("%d/%b at %I:%M%p")
    env_path = Rails.configuration.environment_ids['our_env_path']
    return  "#{product.description} a $#{promotion.precio}. Usa '#{promotion.codigo}'. 
            Desde #{inicio} a #{fin}."+"Ven https://goo.gl/EyzEYq !"


  end

  def self.get_promo_picture(promotion)
    env_path = Rails.configuration.environment_ids['our_env_path']
    product = Product.find(promotion.sku)
    spree_product = Spree::Product.where(name: product.description).first
    return env_path+'spree/products/'+spree_product.id.to_s+'/large/'+spree_product.name.to_s+'.jpg'
  end

  def self.get_promo_local_picture(promotion)
    env_path = Rails.configuration.environment_ids['our_env_path']
    product = Product.find(promotion.sku)
    spree_product = Spree::Product.where(name: product.description).first
    return 'public/spree/products/'+spree_product.id.to_s+'/large/'+spree_product.name.to_s+'.jpg'

  end
  
  def self.publish_on_facebook(promotion)

    facebook_auth = Rails.configuration.environment_ids['facebook_token']
    @user_graph = Koala::Facebook::API.new(facebook_auth)

    pages = @user_graph.get_connections('me', 'accounts')
    facebook_id_page = Rails.configuration.environment_ids['facebook_id_page']
    selected_page = pages.find {|p| p['id']== facebook_id_page}['access_token']
    
    @page_graph = Koala::Facebook::API.new(selected_page)

    options = {
      :message => self.get_beautty_message(promotion),
      :picture => self.get_promo_picture(promotion)
    }
    @page_graph.put_picture(options[:picture], {:caption => options[:message]})


  end

  def self.publish_on_twitter(promotion)


    ## twitter
    @twitter = Twitter::REST::Client.new do |config|
      config.consumer_key = 'MReVzy5O7qXJ0nxEXwrekTjI8'
      config.consumer_secret =  'YqLRtE2ftXOANqoppx8HHB6DyXNHyRAzxxQprNE90hfgxRY5dY'
      config.access_token =   '878628188464836608-4rtAtrGCHOicZLvfsPUZL8NxC0KezdI'
      config.access_token_secret = 'R8GI4W4pY8iokBZ7Yfj6rLcAItRS5XgfqlhKvnIlqDEur'
    end

    msg = self.get_short_beautty_message(promotion)
    pic = self.get_promo_local_picture(promotion)
    @twitter.update_with_media(msg, File.new(pic))


  end

  def self.get_next_promotion

    uri = Rails.configuration.environment_ids['queue']
    b = Bunny.new uri
    b.start
    ch = b.create_channel
    q = ch.queue('ofertas', auto_delete: true)
    delivery, headers, msg = q.pop
    puts msg
    b.close
    if msg != nil
      return JSON.parse msg
    end
    return msg
    
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
            many += Promotions.create(promotion["codigo"], 
                                    Time.at(promotion["inicio"].to_f /  1000), 
                                    Time.at(promotion["fin"].to_f / 1000), 
                                    promotion["sku"], promotion["precio"], promotion["publicar"])
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

    our_product = false
    if producto != nil
      our_product = producto.owner
    else
      return 0
    end


    product_name = producto.description 
    producto_price = producto.price
    producto_price ||= 0
    final_discount = producto_price - precio
    final_discount = [0, final_discount].max

    discount = Discount.create!(
	      sku: sku,
	      precio: precio,
	      inicio: inicio,
	      fin: fin,
	      codigo: codigo,
        publicar: publicar && our_product,
	      owner: our_product,
	      activation_count: 0)

    if our_product
      promotion = Spree::Promotion.create!(
        description: codigo, 
        expires_at: fin, 
        starts_at: inicio, 
        name: self.get_name(product_name, final_discount),
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
      return 1
    end 


    return 0

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
      puts ajuste.promotion.name
      ajuste.promotion.name = self.get_name(product.description, final_discount)
      ajuste.promotion.save!
      puts ajuste.promotion.name

      return discount
    end
    return nil

  end

  def self.get_name(product_name, discount)
    return product_name + " -$" + discount.to_s + " c/u"
  end


end
