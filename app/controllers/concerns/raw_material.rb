module RawMaterial
  # def json_response(object, status = :ok)
  #   render json: object, status: status
  # end
  def comprar_materia_prima(sku, quantity, needed_date)
    product = Product.find(sku)

    # suppliers = product.suppliers
    # puts suppliers

    if product.suppliers
      supplier = get_best_supplier(product)
      supplier_informations = get_best_supplier(product)
      if supplier_informations

        supplier_id = supplier_informations[:supplier_id]
        price = supplier_informations[:price]
        puts "This is the best supplier: #{supplier_informations[:supplier_id]}, PRICE: #{supplier_informations[:price]}"

        Sales.create_purchase_order(2, supplier_id, sku, needed_date, quantity, price, "b2b", "Esta es una nota")

        #Implementar
        supplier = Supplier.find(supplier_informations[:supplier_id])
        status = Purchases.realizar_pedido(supplier, "contra_factura", id_oc)
        if status = 201
          return true #Orden de compra recibida correctamente
        else
          return false #Orden de compra no la recibio bien



      end
    else
      return false
    end
   end
  end

  # Retorna el mejor supplier de un producto
  def get_best_supplier(product)
    #Almacena Hashes con los datos de los productos
    suppliers_products = []
    Contact.where(product: product).each do |contact|
      supplier = contact.supplier
      # Get precio de los productos## para el proveedor

      # La linea de abajo es la que deberia quedar!
      response = Queries.get_to_groups_api("products", supplier, false, {})

      puts "For supplier #{supplier.id}: "
      #puts response.body
      # puts response.code
      # puts response.message
      # puts response.headers.inspect
      begin
        hash_response = JSON.parse(response.body)
        api_product_price = hash_response.find {|prod| prod['sku']== product.sku}['price']
        #h["incidents"].find {|h1| h1['key']=='xyz098'}['number']

        puts "This is the price:"
        # puts hash_response[0]["price"]#.class
        puts api_product_price
        # puts "Behind me is the sku"
        #price = hash_response[0]["price"]
        suppliers_products << {supplier_id: supplier.id, priority: contact.priority, price: api_product_price}
      rescue
        puts "No pudimos sacar info de supplier #{supplier.id}"
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

    else
      return false
    end
  end

end
