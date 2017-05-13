module RawMaterial
  # def json_response(object, status = :ok)
  #   render json: object, status: status
  # end
  def comprar_materia_prima(sku, quantity)
    product = Product.find(sku)

    # suppliers = product.suppliers
    # puts suppliers

    if product.suppliers
      supplier = get_best_supplier(product)
      puts "This is the best supplier: #{supplier.id}"
    else
      return false
    end

  end

  # Retorna el mejor supplier de un producto
  def get_best_supplier(product)
    #Almacena Hashes con los datos de los productos
    suppliers_products = []
    Contact.where(product: product).each do |contact|
      supplier_id = contact.supplier.id
      ##Get precio de los productos## para el proveedor
      #response = Queries.get("http://localhost:3000/products", false)

      header = {	'Content-Type' => 'application/json'}
      # response = HTTParty.get("http://localhost:3000/products", :headers => header )
      response = HTTParty.get("http://integra17-2.ing.puc.cl/products", :headers => header )
      # puts response.body
      # puts response.code
      # puts response.message
      # puts response.headers.inspect
      hash_response = JSON.parse(response.body)

      puts "In front of me me is the sku"
      puts hash_response[0]["price"].class
      puts "Behind me is the sku"
      price = 1000
      suppliers_products << {supplier_id: supplier_id, priority: contact.priority, price: price}
    end
    #Algoritmo que escoge el mejor supplier_id
    best_current_supplier = suppliers_products[0]
    suppliers_products.each do |sp|
      best_current_supplier = sp if sp[:price] < best_current_supplier[:price]
    end
    Supplier.find(best_current_supplier[:supplier_id])
  end





end
