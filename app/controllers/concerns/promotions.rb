module Promotions

  def self.get_beautty_message(promotion)
    product = Product.find(promotion.sku)
    inicio = promotion.inicio.strftime("%d/%b a las %I:%M%p")
    fin = promotion.fin.strftime("%d/%b a las %I:%M%p")
    env_path = Rails.configuration.environment_ids['our_env_path']
    return "Usa el código '#{promotion.codigo}' para poder comprar #{product.description} a solo $#{promotion.precio}. 
            Válido entre #{inicio} y #{fin}. ¡Visítanos en "+env_path+"ecommerce!"
  end

  def self.get_short_beautty_message(promotion)
    product = Product.find(promotion.sku)
    inicio = promotion.inicio.strftime("%d/%b a las %I:%M%p")
    fin = promotion.fin.strftime("%d/%b a las %I:%M%p")
    ecommerce_uri = Rails.configuration.environment_ids['ecommerce_uri']
    s = "#{product.description} a $#{promotion.precio}. Usa '#{promotion.codigo}'. Desde #{inicio} a #{fin}."+"Ven #{ecommerce_uri} !"
    return s[0,140]
  end

  def self.get_promo_picture(promotion)
    env_path = Rails.configuration.environment_ids['our_env_path']
    product = Product.find(promotion.sku)
    spree_product = Spree::Product.where(name: product.description).first
    pic_name = spree_product.images[0].attachment.to_s
    pic_name = pic_name.split('/')[-1].split('?')[0]
    return env_path+'spree/products/'+spree_product.id.to_s+'/large/'+pic_name
  end

  def self.get_promo_local_picture(promotion)
    env_path = Rails.configuration.environment_ids['our_env_path']
    product = Product.find(promotion.sku)
    spree_product = Spree::Product.where(name: product.description).first
    pic_name = spree_product.images[0].attachment.to_s
    pic_name = pic_name.split('/')[-1].split('?')[0]
    return 'public/spree/products/'+spree_product.id.to_s+'/large/'+pic_name
  end
  
  def self.publish_on_facebook(promotion)

    options = {
      :message => self.get_beautty_message(promotion),
      :picture => self.get_promo_picture(promotion)
    }

    facebook_auth = Rails.configuration.environment_ids['facebook_token']
    @user_graph = Koala::Facebook::API.new(facebook_auth)

    pages = @user_graph.get_connections('me', 'accounts')
    facebook_id_page = Rails.configuration.environment_ids['facebook_id_page']
    selected_page = pages.find {|p| p['id']== facebook_id_page}['access_token']
    
    @page_graph = Koala::Facebook::API.new(selected_page)

    @page_graph.put_picture(options[:picture], {:caption => options[:message]})

    promotion.facebook_times += 1
    promotion.save!

  end

  def self.publish_on_twitter(promotion)

    @twitter = Twitter::REST::Client.new do |config|

      config.consumer_key = Rails.configuration.environment_ids['twitter_consumer_key']         
      config.consumer_secret = Rails.configuration.environment_ids['twitter_consumer_secret']      
      config.access_token = Rails.configuration.environment_ids['twitter_access_token']         
      config.access_token_secret = Rails.configuration.environment_ids['twitter_access_token_secret']  

    end

    msg = self.get_short_beautty_message(promotion)
    pic = self.get_promo_local_picture(promotion)
    @twitter.update_with_media(msg, File.new(pic))

    promotion.twitter_times += 1
    promotion.save!

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

  def self.publish_discounts

    publicar_twt = Discount.current.where(publicar: true).where(twitter_times: 0)
    publicar_fb = Discount.current.where(publicar: true).where(facebook_times: 0)

    publicar_twt.each do |prom|
      Promotions.publish_on_twitter(prom)
    end

    publicar_fb.each do |prom|
      Promotions.publish_on_facebook(prom)
    end

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

        Promotions.publish_discounts

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
