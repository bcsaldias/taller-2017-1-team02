module RawMaterial
  # def json_response(object, status = :ok)
  #   render json: object, status: status
  # end

  #proceso de comprar_materia_prima
  def comprar_materia_prima(sku, quantity, needed_date)
    product = Product.find(sku)

    return false unless product.suppliers #FALSE si no hay proveedores del producto

    supplier_informations = get_best_supplier(product)

    return false unless supplier_informations #FALSE si preciosdeproveedores son inaccesibles

    supplier_id = supplier_informations[:supplier_id]
    supplier = Supplier.find(supplier_informations[:supplier_id])
    price = supplier_informations[:price]
    puts "This is the best supplier: #{supplier_informations[:supplier_id]},
                                      PRICE: #{supplier_informations[:price]}"

    status = Purchases.create_purchase_order(2, supplier.id_cloud, sku, needed_date,
                                          quantity, price, "b2b", "Esta es una nota")

    if status == 200 or status == 201
      return true #OC creada y recibida correctamente por el supplier
    else #OC fallo en algun punto del proceso
      return false
    end

  end

  # Retorna el mejor supplier de un producto
  def get_best_supplier(product)
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
        suppliers_products << {supplier_id: supplier.id, priority: contact.priority, price: api_product_price}
      rescue
        puts "No pudimos obtener info de supplier #{supplier.id}"
      end
    end

    #Algoritmo que escoge el mejor supplier_id
    puts "Largo: #{suppliers_products.length}"
    if suppliers_products.length
      best_current_supplier = suppliers_products[0]
      suppliers_products.each do |sp|
         best_current_supplier = sp if sp[:price] < best_current_supplier[:price]
      end
      # puts "supplier id: #{best_current_supplier[:supplier_id]}"
      # supplier = Supplier.find(best_current_supplier[:supplier_id])
      # price =
      #Supplier.find(best_current_supplier[:supplier_id])
      return best_current_supplier

    else # No se pudo acceder a precios de ningun proveedor
      return false
    end
  end
end
