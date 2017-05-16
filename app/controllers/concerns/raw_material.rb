module RawMaterial
  # def json_response(object, status = :ok)
  #   render json: object, status: status
  # end

  # Proceso que permite obtener una materia prima, retorna true si la logra comprar
  # o producir
  def self.restore_stock(sku, quantity, needed_date = Tiempo.tiempo_a_milisegundos(12, 30, 23, 59))
    product = Product.find(sku)

    return false unless product.suppliers #FALSE si no hay proveedores del producto

    #Arreglo de Hashes
    suppliers_products_info = RawMaterial.get_suppliers_ordered_by_priority(product, quantity)
    puts "Suppliers_products_info:"
    puts suppliers_products_info
    return false unless suppliers_products_info #FALSE si preciosdeproveedores son inaccesibles

    compra_realizada = false
    suppliers_products_info.each do |supplier_info|
      #Itera por cada proveedor, cuando a uno le pueda comprar satisfactoriamente sale del loop
      supplier_id = supplier_info[:supplier_id]
      supplier = Supplier.find(supplier_info[:supplier_id])
      price = supplier_info[:price]

      #whouse_space = Espacio en fecha de llegada (No implementado)
      order_quantity = RawMaterial.calculate_order_quantity(quantity,
                            supplier_info[:min_production_batch])#, whouse_space)
      return false unless order_quantity # False si no hay espacio en bodega
      puts "This is the best supplier: #{supplier_info[:supplier_id]},
                                        PRICE: #{supplier_info[:price]}"

      if supplier.id == 2 # Proveedor somos nosotros
        ## Mandar a producir a nosotros mismos
        puts 'LLAMANDO A METODO QUE PRODUCE MP (hacer_pedido_interno)'
        status = Factory.hacer_pedido_interno(sku, order_quantity)
        if status
           compra_realizada = true
           break
        end

      else
        our_id = Rails.configuration.environment_ids['team_id']
        status = Purchases.create_purchase_order(our_id, supplier.id_cloud, sku, needed_date,
                                        order_quantity, price, "b2b", "Esta es una nota")

        if status == 200 or status == 201
          compra_realizada = true #OC creada y recibida correctamente por el supplier
          break
        end
      end
    end

    if compra_realizada # Retorna true si se creo satisfactoriamente la OC o se mando la OC
      puts "restore_stock retorna true"
      return true
    else
      puts "restore_stock retorna false"
      return false
    end

  end


  # Retorna los mejor suppliers de un producto, ordenados
  def self.get_suppliers_ordered_by_priority(product, quantity_oc)
    # Comentario de mejora: Solo el metodo JSON.parse(response.body) deberia estar
    # en el exception handler. Asi es mas facil debuguear

    #Almacena Hashes con los datos de los productos
    suppliers_products = []
    Contact.where(product: product).each do |contact|
      supplier = contact.supplier

      puts "Conectando con supplier #{supplier.id}: "

      if supplier.id != 2 && RawMaterial.supplier_has_rejected_previous_po(supplier, product.sku, quantity_oc)
        puts "No conectar con supplier pq tiene OC previas rechazadas"
        next
      end

      response = Queries.get_to_groups_api("products", supplier, false, {})

      begin
        hash_response = JSON.parse(response.body)
        api_product_price = hash_response.find {|prod| prod['sku']== product.sku}['price']
        puts "El precio es: #{api_product_price}"
        suppliers_products << {supplier_id: supplier.id, priority: contact.priority,
                price: api_product_price, min_production_batch: contact.min_production_batch}
      rescue
        puts "Imposible obtener precios de supplier #{supplier.id}"
      end
    end

    #Algoritmo que ordena supplier_products
    puts "Largo: #{suppliers_products.length}"
    largo = suppliers_products.length
    if suppliers_products.length
      ordered_suppliers_products = suppliers_products.sort_by { |hash| hash[:price] }
    else
      return false
    end
  end



  # Retorna true si ultima OC del sku de ese supplier fue rechazada, false en caso contrario
  #fix me (no esta testeado)
  def self.supplier_has_rejected_previous_po(supplier, sku, quantity)
    # Comentario de mejora: Se deberia escoger la ultima PO del supplier ordenandolas
    # por fecha en que se edito su estado, no fecha de creacion.

    # puts "EN supplier_has_not_rejected_previous_po, supplier: #{supplier.id}"
    # sku = Product.first.sku

    # Si ultima OC del proveedor es de ese producto y esta rechazada, retornar true
    purchase_orders = PurchaseOrder.where(supplier: supplier, owner: true).order(updated_at: :asc)
    return false if purchase_orders.count == 0
    # if purchase_orders.count == 0
    #   puts "No hay ordenes de compra emitidas a ese supplier => return true"
    #   return false
    # end

    po_last = purchase_orders.last
    how_long_ago = (Time.now() - po_last.created_at).to_i#.abs

    puts "#{Time.now()} MENOS #{po_last.created_at}  = #{how_long_ago} "

    # Revisa q sea mismo sku, misma cant, q este rechazada y que hayan pasado menos de 3600s desde creacion.
    return false unless po_last.rechazada?
    return false unless po_last.product_sku == sku
    return false unless po_last.quantity == quantity
    return false unless how_long_ago < 3600

    puts "Ultima OC de supplier #{supplier.id}, sku: #{sku} por #{quantity} productos
                  fue rechazada hace #{how_long_ago}"
    return true
  end



  #Devuelve la cantidad a producir, si no hay espacio
  def self.calculate_order_quantity(quantity, min_batch, whouse_space = 2000000)
    if min_batch > quantity
      producir = min_batch
    else
      n_min_batches = (quantity / min_batch).round()
      n_min_batches += 1 unless quantity % min_batch == 0
      producir = n_min_batches * min_batch
      puts "producir: #{producir}, wh: #{whouse_space}"
    end
    #return producir unless producir > whouse_space
    return producir
  end



  #fix me
  #Compra productos  a un supplier especifico. Recibe objeto supplier como parametro
  def self.buy_product_from_supplier(sku, quantity, supplier, needed_date = Tiempo.tiempo_a_milisegundos(12, 30, 23, 59))
    Tiempo.tiempo_a_milisegundos(12, 30, 23, 59)
    puts "FECHA!!! : #{needed_date}"
    product = Product.find(sku)
    contacts = product.contacts.where(supplier_id: supplier.id)

    return false if contacts.length < 1
    contact = contacts.first

    supplier = Supplier.where(id: 2).first
    response = Queries.get_to_groups_api("products", supplier, false, {})
    begin
      hash_response = JSON.parse(response.body)
      price = hash_response.find {|prod| prod['sku']== product.sku}['price']
      puts "El precio es: #{price}"
    rescue
      puts "Imposible obtener el precio del producto en la api del supplier"
      return false
    end
    order_quantity = RawMaterial.calculate_order_quantity(quantity, contact.min_production_batch)
    our_id = Rails.configuration.environment_ids['team_id']
    status = Purchases.create_purchase_order(our_id, supplier.id_cloud, sku, needed_date,
                                        order_quantity, price, "b2b", "Esta es una nota")

    if status == 200 or status == 201
      puts "OC generada y enviada"
      return true
    end
    puts "No fue posible notificarle al supplier de la OC"
    false
  end





end
