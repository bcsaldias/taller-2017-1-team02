module RawMaterial
  # def json_response(object, status = :ok)
  #   render json: object, status: status
  # end

  #Copiado del de abajo, pero completo
  def proceso_comprar_materia_prima(sku, quantity, needed_date)
    # Por programar
    # Encargar un min_production_batch

    product = Product.find(sku)

    return false unless product.suppliers #FALSE si no hay proveedores del producto

    suppliers_products_info = get_suppliers_ordered_by_priority(product) #Arreglo de Hashes
    puts "!!!!Suppliers_products_info:"
    puts suppliers_products_info
    return false unless suppliers_products_info #FALSE si preciosdeproveedores son inaccesibles

    compra_realizada = false
    suppliers_products_info.each do |supplier_info|
      #Itera por cada proveedor, cuando a uno le pueda comprar satisfactoriamente sale del loop
      supplier_id = supplier_info[:supplier_id]
      supplier = Supplier.find(supplier_info[:supplier_id])
      price = supplier_info[:price]

      #fix me
      #whouse_space = Espacio en fecha de llegada
      whouse_space = 1000
      order_quantity = calculate_order_quantity(quantity,
                            supplier_info[:min_production_batch], whouse_space)
      return false unless order_quantity # False si no hay espacio en bodega
      puts "This is the best supplier: #{supplier_info[:supplier_id]},
                                        PRICE: #{supplier_info[:price]}"

      if supplier.id == 2 # Proveedor somos nosotros
        ## Mandar a producir a nosotros mismos
        puts 'Desarrollar metodo para producir materias'
        status = producir_materia_prima(sku, order_quantity)
        # if status
        #   compra_realizada = true
        #   break
        # end
        ###
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

    if compra_realizada # Retorna true cuando se creo satisfactoriamente la OC
      return true
    else
      return false
    end


  end




  #proceso de comprar_materia_prima
  # def comprar_materia_prima(sku, quantity, needed_date)
  #   # Por programar
  #   # Encargar un min_production_batch
  #
  #   product = Product.find(sku)
  #
  #   return false unless product.suppliers #FALSE si no hay proveedores del producto
  #
  #   supplier_informations = get_best_supplier(product)
  #
  #   return false unless supplier_informations #FALSE si preciosdeproveedores son inaccesibles
  #
  #   supplier_id = supplier_informations[:supplier_id]
  #   supplier = Supplier.find(supplier_informations[:supplier_id])
  #   price = supplier_informations[:price]
  #   order_quantity = calculate_order_quantity(quantity, supplier_informations[:min_production_batch])
  #   return false unless order_quantity # False si no hay espacio en bodega
  #   puts "This is the best supplier: #{supplier_informations[:supplier_id]},
  #                                     PRICE: #{supplier_informations[:price]}"
  #
  #   if supplier.id == 2 # El mejor proveedor somos nosotros
  #     ## Mandar a producir a nosotros mismos
  #     puts 'Desarrollar metodo para producir materias'
  #     producir_materia_prima(sku, order_quantity)
  #     ###
  #   else
  #     status = Purchases.create_purchase_order(2, supplier.id_cloud, sku, needed_date,
  #                                     order_quantity, price, "b2b", "Esta es una nota")
  #
  #     if status == 200 or status == 201
  #       return true #OC creada y recibida correctamente por el supplier
  #     else #OC fallo en algun punto del proceso
  #       return false
  #     end
  #
  #   end
  # end
  #
  # # Retorna el mejor supplier de un producto
  # def get_best_supplier(product)
  #   #Almacena Hashes con los datos de los productos
  #   suppliers_products = []
  #   Contact.where(product: product).each do |contact|
  #     supplier = contact.supplier
  #     response = Queries.get_to_groups_api("products", supplier, false, {})
  #
  #     puts "For supplier #{supplier.id}: "
  #     # puts response.body
  #     # puts response.code
  #     # puts response.message
  #     # puts response.headers.inspect
  #     begin
  #       hash_response = JSON.parse(response.body)
  #       api_product_price = hash_response.find {|prod| prod['sku']== product.sku}['price']
  #       puts "This is a price: #{api_product_price}"
  #       suppliers_products << {supplier_id: supplier.id, priority: contact.priority,
  #         price: api_product_price, min_production_batch: contact.min_production_batch}
  #     rescue
  #       puts "No pudimos obtener info de supplier #{supplier.id}"
  #     end
  #   end
  #
  #   #Algoritmo que escoge el mejor supplier_id
  #   puts "Largo: #{suppliers_products.length}"
  #   if suppliers_products.length
  #     best_current_supplier = suppliers_products[0]
  #     suppliers_products.each do |sp|
  #        best_current_supplier = sp if sp[:price] < best_current_supplier[:price]
  #     end
  #     # puts "supplier id: #{best_current_supplier[:supplier_id]}"
  #     # supplier = Supplier.find(best_current_supplier[:supplier_id])
  #     # price =
  #     #Supplier.find(best_current_supplier[:supplier_id])
  #     return best_current_supplier
  #
  #   else # No se pudo acceder a precios de ningun proveedor
  #     return false
  #   end
  # end




  # Retorna los mejor suppliers de un producto, ordenados
  def get_suppliers_ordered_by_priority(product)
    #Almacena Hashes con los datos de los productos
    suppliers_products = []
    Contact.where(product: product).each do |contact|
      supplier = contact.supplier
      response = Queries.get_to_groups_api("products", supplier, false, {})

      puts "For supplier #{supplier.id}: "
      # puts response.body
      # puts response.code
      # puts response.message
      # puts response.headers.inspect
      begin
        hash_response = JSON.parse(response.body)
        api_product_price = hash_response.find {|prod| prod['sku']== product.sku}['price']
        puts "This is a price: #{api_product_price}"
        suppliers_products << {supplier_id: supplier.id, priority: contact.priority,
          price: api_product_price, min_production_batch: contact.min_production_batch}
      rescue
        puts "No pudimos obtener info de supplier #{supplier.id}"
      end
    end

    #Algoritmo que ordena supplier_products
    puts "Largo: #{suppliers_products.length}"
    largo = suppliers_products.length
    if suppliers_products.length
      ordered_suppliers_products = suppliers_products.sort_by { |hash| hash[:price] }
      # array_of_hashes.sort_by { |hsh| hsh[:zip] }
    else
      return false
    end
  end







  def calculate_order_quantity(quantity, min_batch, whouse_space)
    if min_batch > quantity
      producir = min_batch
    else
      n_min_batches = (quantity / min_batch).round()
      n_min_batches += 1 unless quantity % min_batch == 0
      producir = n_min_batches * min_batch
      puts "producir: #{producir}, wh: #{whouse_space}"
    end
    return producir unless producir > whouse_space
  end

  # def producir_materia_prima(sku, order_quantity)
  #   ###Escribir metodo!!
  # end

end
