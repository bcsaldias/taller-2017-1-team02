module Warehouses
  include Production
  include Factory

#retorna los id de cada warehouse en forma de diccionario
  def self.get_warehouses_id
    warehouses_id = {}
    warehouses = Production.get_warehouses
    general = true

    for warehouse in warehouses
      if warehouse['pulmon']
        warehouses_id['pulmon'] = warehouse['_id']
      elsif warehouse['despacho']
        warehouses_id['despacho'] = warehouse['_id']
      elsif warehouse['recepcion']
        warehouses_id['recepcion'] = warehouse['_id']
      elsif !warehouse['recepcion'] && !warehouse['despacho'] && !warehouse['pulmon'] && general
        general_1 = warehouse['_id']
        general_1_cap = warehouse['totalSpace']
        # puts "general 1 ", general_1_cap
        general = false
      elsif !warehouse['recepcion'] && !warehouse['despacho'] && !warehouse['pulmon'] && !general
        general_2 = warehouse['_id']
        general_2_cap = warehouse['totalSpace']
        # puts "general 2 ", general_2_cap
      end
    end

    # La bodega general sera la mas grande, la otra es la pregeneral
    if general_1_cap > general_2_cap
      warehouses_id['general'] = general_1
      warehouses_id['pregeneral'] = general_2
    else
      warehouses_id['general'] = general_2
      warehouses_id['pregeneral'] = general_1
    end

    return warehouses_id
  end

#retorna el espacio libre de cada warehouse en forma de diccionario
  def self.get_warehouses_space
    warehouses_space = {}
    warehouses = Production.get_warehouses

    for warehouse in warehouses
      if warehouse.pulmon
        warehouses_space['pulmon'] = warehouse['totalSpace'] - warehouse['usedSpace']
      elsif warehouse.despacho
        warehouses_id['despacho'] = warehouse['totalSpace'] - warehouse['usedSpace']
      elsif warehouse.recepcion
        warehouses_id['recepcion'] = warehouse['totalSpace'] - warehouse['usedSpace']
      else
        warehouses_id['general'] = warehouse['totalSpace'] - warehouse['usedSpace']
      end
    end

    return warehouses_id
  end

  # metodo que evalua si podemos vender q_asked de cierto sku
  # retorna true si es que tenemos en las bodegas la cantidad pedida de un sku determinado. False en caso contrario
    def self.product_availability(sku, q_asked)
      stock_actual = self.product_stock(sku)
      if stock_actual >= q_asked
        return true
      else
        return false
      end
    end


    #preparar bodega para despachar
    #retorna true si queda lista, un int indicando cuantos productos del sku deja en la bodega de despacho
  def self.get_despacho_ready(sku, q_a_despachar)
    sleep_time = 1
    max_request = 50
    warehouses_id = self.get_warehouses_id

    #stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)
    cantidad_en_despacho = self.product_stock_in(warehouses_id['despacho'], sku)

    a = [1,2,4]
    contador_de_requests = 0

    puts "q_a_despachar"
    puts q_a_despachar
    puts "q_en_despacho"
    puts cantidad_en_despacho
    available = self.product_availability(sku, q_a_despachar)
    puts "producto disponible?"
    puts available
    while (available and q_a_despachar > cantidad_en_despacho)
      puts "cantidad_en_despacho: #{cantidad_en_despacho}"

      stock_in_general = self.product_stock_in(warehouses_id['general'], sku)  #Production.get_stock(warehouses_id['general'], sku)
      stock_in_pregeneral = self.product_stock_in(warehouses_id['pregeneral'], sku)  #Production.get_stock(warehouses_id['pregeneral'],sku)
      stock_in_recepcion = self.product_stock_in(warehouses_id['recepcion'], sku)  #Production.get_stock(warehouses_id['recepcion'], sku)
      stock_in_pulmon = self.product_stock_in(warehouses_id['pulmon'], sku)  #Production.get_stock(warehouses_id['pulmon'], sku)

      puts "comienza while"
      if (stock_in_general == 0 and stock_in_recepcion == 0 and stock_in_pulmon == 0 and stock_in_pregeneral == 0)
        break
      else

        stock_general = Production.get_stock(warehouses_id['general'], sku)
        for product in stock_general
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['despacho'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > max_request
            contador_de_requests = 0
            sleep(sleep_time)
          end
          cantidad_en_despacho += 1
          # puts "general a despacho"
        end


        stock_pregeneral = Production.get_stock(warehouses_id['pregeneral'], sku)
        for product in stock_pregeneral
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['general'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > max_request
            contador_de_requests = 0
            sleep(sleep_time)
          end
          # puts "pregeneral a general"
        end

        stock_recepcion = Production.get_stock(warehouses_id['recepcion'], sku)
        for product in stock_recepcion
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['pregeneral'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > max_request
            contador_de_requests = 0
            sleep(sleep_time)
          end
          # puts "recepcion a pregeneral"
        end

        stock_pulmon = Production.get_stock(warehouses_id['pulmon'], sku)
        for product in stock_pulmon
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['recepcion'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > max_request
            contador_de_requests = 0
            sleep(sleep_time)
          end
        end
      end
    end

    puts "termina while"
    puts sku
    cantidad_en_despacho = self.product_stock_in(warehouses_id['despacho'], sku)
    puts cantidad_en_despacho
    puts "return"
    if  q_a_despachar <= cantidad_en_despacho
      puts "get_despacho_ready: Productos listos en despacho!"
      return true
    else
      puts "get_despacho_ready: No fue posible poner todos los productos necesarios en bodega"
      return false
    end
  end

#despachar_OC despacha las ordenes de compra
  def self.despachar_OC(id_cloud_OC, distribuidor=false)
    purchase_order = Sales.get_purchase_order(id_cloud_OC)
    our_purchase_order = PurchaseOrder.where(id_cloud: id_cloud_OC).first

    puts purchase_order
    puts purchase_order["sku"], purchase_order["cantidad"]

    #q_to_send = purchase_order["cantidad"].to_i - purchase_order["cantidadDespachada"].to_i

    q_to_send = our_purchase_order.quantity - our_purchase_order.quantity_done
    puts "q_to_send", q_to_send
    ret = self.get_despacho_ready(purchase_order["sku"], q_to_send)


    puts "ret", ret
    price = purchase_order['precioUnitario']
    puts("price",price)

    #our_purchase_order = our_purchase_order
    #our_purchase_order.quantity_done = purchase_order["cantidadDespachada"].to_i
    #our_purchase_order.save!

    if not ret
      our_purchase_order.delivering = false
      our_purchase_order.save!
    end

    if ret and  q_to_send > 0

      puts "our_purchase_order", our_purchase_order
      client_warehouse = our_purchase_order['id_store_reception']
      puts "client_warehouse", client_warehouse

      warehouses_id = self.get_warehouses_id

      count = 0
      index_count = 0

      while count < q_to_send
        stock_a_despachar = Production.get_stock(warehouses_id['despacho'], purchase_order["sku"])


        puts "stock_a_despachar"
        puts stock_a_despachar
        puts "stock_a_despachar"

        #for product in stock_a_despachar
        index_count = 0
        while count < q_to_send

          product = stock_a_despachar[index_count]
          puts "DESPACHAR"
          puts our_purchase_order.quantity_done
          puts product

          if distribuidor
            ret = Production.delete_ftp_stock('distribuidor', product['_id'],
                                                  id_cloud_OC, price)
          else
            ret = Production.move_stock_external(client_warehouse, product['_id'],
                                                  id_cloud_OC, price)
          end

          puts "ret2"
          puts ret
          if ret.code == 200 or ret.code == 201

            count += 1
            index_count += 1

            _value = our_purchase_order.quantity_done
            our_purchase_order.quantity_done = _value + 1
            our_purchase_order.save!

            if count.to_i == q_to_send.to_i
              our_purchase_order.state = 3
              our_purchase_order.save!
              our_purchase_order.delivering = false
              our_purchase_order.save!
              return true
            end
          else
            return false
          end
        end
      end


    end
  end

#retorna true si el almacen esta lleno, y false si aun tiene espacio libre
  def self.full_warehouse(warehouse_id)
    warehouses = Production.get_warehouses
    for warehouse in warehouses
      if warehouse['_id'] == warehouse_id
        space = warehouse['totalSpace']-warehouse['usedSpace']
        if space == 0
          return true
        else
          return false
        end
      end
    end
  end

#retorna true si el almacen esta vacio, y false si tiene algun elemento
  def self.empty_warehouse(warehouse_id)
    warehouses = Production.get_warehouses
    usedSpace = 0
    for warehouse in warehouses
      if warehouse['_id'] == warehouse_id
        usedSpace = warehouse['usedSpace']
        if usedSpace == 0
          return true
        else
          return false
        end
      end
    end
  end

  #ordena los almacenes, dejando la mayoria en general

  def self.puede_reordenar_ok
    PurchaseOrder.where(delivering: true).count == 0
  end


  def self.sort_warehouses
    sleep_time = 1
    max_request_counter = 50
    moving_batch = 40
    puts "starting reorder"
    warehouses_id = self.get_warehouses_id
    stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
    stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
    request_counter = 0

    Rails.application.config.able_to_reorder = true
    while Rails.application.config.able_to_reorder
      puts "\n \nIteracion:"
      puts "General: #{stock_general}"
      puts "Pregeneral: #{stock_pregeneral}"
      puts "Recepcion: #{stock_recepcion}"
      puts "Pulmon: #{stock_pulmon}"
      puts "Despacho: #{stock_despacho}"

      if stock_despacho.length == 0 and stock_pregeneral.length == 0 and stock_recepcion.length == 0 and stock_pulmon.length == 0
        puts "Todo ordenado!"
        return true
      elsif self.full_warehouse(warehouses_id['general']) and self.full_warehouse(warehouses_id['pregeneral'])
        puts "Se llenaron las bodegas general y pregeneral"
        return true
      else

        # DESPACHO -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['despacho'])
          puts "Entro a Despacho -> General"
          for product_type in stock_despacho
            stock_despacho_sku = Production.get_stock(warehouses_id['despacho'], product_type['_id'])

            cant_a_mover = [stock_despacho_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_despacho_sku[n]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved D->G"
              request_counter += 1
            end
             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end

        # PREGENERAL -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['pregeneral'])
          puts "Entro a PREGENERAL -> GENERAL"
          for product_type in stock_pregeneral
            stock_pregeneral_sku = Production.get_stock(warehouses_id['pregeneral'], product_type['_id'])

            cant_a_mover = [stock_pregeneral_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_pregeneral_sku[n]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved P->G"
              request_counter += 1
            end

            request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end

        # RECEPCION -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['recepcion'])
          puts "Entro a RECEPCION -> GENERAL"
          for product_type in stock_recepcion
            stock_recepcion_sku = Production.get_stock(warehouses_id['recepcion'], product_type['_id'])

            cant_a_mover = [stock_recepcion_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_recepcion_sku[n]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved R->G"
              request_counter += 1
            end
            request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end

        # PULMON -> RECEPCION
        if !self.full_warehouse(warehouses_id['recepcion']) and !self.empty_warehouse(warehouses_id['pulmon'])
          puts "Entro a PULMON -> RECEPCION"
          for product_type in stock_pulmon
            stock_pulmon_sku = Production.get_stock(warehouses_id['pulmon'], product_type['_id'])

            cant_a_mover = [stock_pulmon_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_pulmon_sku[n]['_id']
              Production.move_stock(warehouses_id['recepcion'], product_id)
              puts "somethg moved P->R"
              request_counter += 1
            end

             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
        end
      end
      puts "\n \nAble_to_order: #{Rails.application.config.able_to_reorder}"
    end
    puts "No Ordenado"#, retorno false (puede ser por estar despachando)"
    return false
  end


 def self.product_stock_in(warehouse_id, sku)
      count = 0
      stock_general = Production.get_all_stock_warehouse(warehouse_id)
      for _object in stock_general
        if _object["_id"] == sku
          count += _object["total"]
        end
      end
      return count
 end

 def self.product_stock(sku)

      warehouses = Production.get_warehouses
      count = 0
      warehouses.each do |wh|
        count += self.product_stock_in(wh["_id"], sku)
      end

      #warehouses_id = self.get_warehouses_id
      #count = 0
      #count += self.product_stock_in(warehouses_id, "general")
      #count += self.product_stock_in(warehouses_id, "pregeneral")
      #count += self.product_stock_in(warehouses_id, "recepcion")
      #count += self.product_stock_in(warehouses_id, "general")
      #count += self.product_stock_in(warehouses_id, "pulmon")
      #count += self.product_stock_in(warehouses_id, "despacho")

      return count
  end


# chequea si hay que comprar mas de algun producto y manda a comprar el producto en particular
  def self.check_and_restore_stock
    warehouses_id = self.get_warehouses_id
    lista_de_productos = Product.where(owner: true)
    cantidad_de_productos = lista_de_productos.length
    cantidad_deseada = 25000/cantidad_de_productos
    cantidad_minima = 15000/cantidad_de_productos

    for producto in lista_de_productos
      sku = producto['sku']
      stock_general = Production.get_stock(warehouses_id['general'],sku)
      stock_pregeneral = Production.get_stock(warehouses_id['pregeneral'],sku)
      stock_recepcion = Production.get_stock(warehouses_id['recepcion'],sku)
      stock_pulmon = Production.get_stock(warehouses_id['pulmon'],sku)
      stock_actual = stock_general.length + stock_pregeneral.length + stock_recepcion.length + stock_pulmon.length

      if stock_actual < cantidad_minima
        cantidad_por_comprar = cantidad_deseada - stock_actual
        # puts sku, "por comprar", cantidad_por_comprar
        RawMaterial.restore_stock(sku, cantidad_por_comprar)
      end

    end
  end


  def self.move_despacho_general
    sleep_time = 6
    max_request_counter = 50
    moving_batch = 40
    warehouses_id = self.get_warehouses_id

    stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
    request_counter = 0

    Rails.application.config.able_to_reorder = true
    while Rails.application.config.able_to_reorder #Crear boton que permita parar esto #self.puede_reordenar_ok
      puts "\n \nIteracion:"
      puts "General: #{stock_general}"
      puts "Despacho: #{stock_despacho}"

      if stock_despacho.length == 0
        puts "Nada en despacho!"
        return true
      elsif self.full_warehouse(warehouses_id['general'])
        puts "Se llenaron las bodegas general"
        return true
      else
        # DESPACHO -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['despacho'])
          puts "Entro a Despacho -> General"
          for product_type in stock_despacho
            stock_despacho_sku = Production.get_stock(warehouses_id['despacho'], product_type['_id'])

            cant_a_mover = [stock_despacho_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_despacho_sku[n]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved Desp->Gen"
              request_counter += 1
            end
             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end
      end
      puts "\n \nAble_to_order: #{Rails.application.config.able_to_reorder}"
    end
  end



  def self.move_recepcion_general
    sleep_time = 6
    max_request_counter = 50
    moving_batch = 40
    warehouses_id = self.get_warehouses_id

    stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    request_counter = 0

    Rails.application.config.able_to_reorder = true
    while Rails.application.config.able_to_reorder #self.puede_reordenar_ok
      puts "\n \nIteracion:"
      puts "General: #{stock_general}"
      puts "Recepcion: #{stock_recepcion}"

      if stock_recepcion.length == 0
        puts "Nada en recepcion!"
        return true
      elsif self.full_warehouse(warehouses_id['general'])
        puts "Se llenaron las bodegas general"
        return true
      else
        # RECEPCION -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['recepcion'])
          puts "Entro a RECEPCION -> GENERAL"
          for product_type in stock_recepcion
            stock_recepcion_sku = Production.get_stock(warehouses_id['recepcion'], product_type['_id'])

            cant_a_mover = [stock_recepcion_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_recepcion_sku[n]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved Recep->Gen"
              request_counter += 1
            end
            request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
          end
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end
      end
      puts "\n \nAble_to_order: #{Rails.application.config.able_to_reorder}"
    end
  end




end
