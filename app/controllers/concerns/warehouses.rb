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
    sleep_time = 3
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
    while (available and q_a_despachar > cantidad_en_despacho and not (q_a_despachar > 2050 and cantidad_en_despacho > 2050) )
      puts "cantidad_en_despacho: #{cantidad_en_despacho}"

      stock_in_general = self.product_stock_in(warehouses_id['general'], sku)  #Production.get_stock(warehouses_id['general'], sku)
      stock_in_pregeneral = self.product_stock_in(warehouses_id['pregeneral'], sku)  #Production.get_stock(warehouses_id['pregeneral'],sku)
      stock_in_recepcion = self.product_stock_in(warehouses_id['recepcion'], sku)  #Production.get_stock(warehouses_id['recepcion'], sku)
      stock_in_pulmon = self.product_stock_in(warehouses_id['pulmon'], sku)  #Production.get_stock(warehouses_id['pulmon'], sku)

      puts "comienza while"
      if (stock_in_general == 0 and stock_in_recepcion == 0 and stock_in_pulmon == 0 and stock_in_pregeneral == 0)
        puts "no hay stock en realidad"
        break

      #elsif self.full_warehouse(warehouses_id['recepcion'])
      #  self.move_A_B('recepcion', 'pulmon', 10)

      else

        stock_general = Production.get_stock(warehouses_id['general'], sku)
        for product in stock_general
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          ret_code = Production.move_stock(warehouses_id['despacho'], product['_id'])

          if ret_code == 200 or ret_code == 201
            cantidad_en_despacho += 1
            contador_de_requests +=1
            if contador_de_requests > max_request
              contador_de_requests = 0
              sleep(sleep_time)
            end
            # puts "general a despacho"
          else
            break
          end

        end


        stock_pregeneral = Production.get_stock(warehouses_id['pregeneral'], sku)
        for product in stock_pregeneral
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          ret_code = Production.move_stock(warehouses_id['general'], product['_id'])

          if ret_code == 200 or ret_code == 201
            contador_de_requests +=1
            if contador_de_requests > max_request
              contador_de_requests = 0
              sleep(sleep_time)
            end
          else
            break
          end


          # puts "pregeneral a general"
        end

        stock_recepcion = Production.get_stock(warehouses_id['recepcion'], sku)
        for product in stock_recepcion
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          ret_code = Production.move_stock(warehouses_id['pregeneral'], product['_id'])

          if ret_code == 200 or ret_code == 201
            contador_de_requests +=1
            if contador_de_requests > max_request
              contador_de_requests = 0
              sleep(sleep_time)
            end
          else
            break
          end

          # puts "recepcion a pregeneral"
        end

        stock_pulmon = Production.get_stock(warehouses_id['pulmon'], sku)
        for product in stock_pulmon
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          ret_code = Production.move_stock(warehouses_id['recepcion'], product['_id'])
          if ret_code == 200 or ret_code == 201
            contador_de_requests +=1
            if contador_de_requests > max_request
              contador_de_requests = 0
              sleep(sleep_time)
            end
          else
            break
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

    if not ret and q_to_send <= 2050  
      our_purchase_order.delivering = false
      our_purchase_order.save!
    end
    
    warehouses_id = self.get_warehouses_id
    cantidad_en_despacho = self.product_stock_in(warehouses_id['despacho'], purchase_order["sku"])

    if (ret or q_to_send > 2050 ) and  q_to_send > 0 and cantidad_en_despacho > 0

      puts "our_purchase_order", our_purchase_order
      client_warehouse = our_purchase_order['id_store_reception']
      puts "client_warehouse", client_warehouse


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

          if index_count == 99
            stock_a_despachar = Production.get_stock(warehouses_id['despacho'], purchase_order["sku"])
            index_count = 0
          end

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
              our_purchase_order.delivering = false
              our_purchase_order.queued = false
              our_purchase_order.save!

              if distribuidor == false
                Invoices.delivered_invoice(id_cloud_OC)
              end

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
        space = warehouse['totalSpace'].to_i-warehouse['usedSpace'].to_i
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
        usedSpace = warehouse['usedSpace'].to_i
        if usedSpace == 0
          return true
        else
          return false
        end
      end
    end
  end


  def self.puede_reordenar_ok
    PurchaseOrder.where(delivering: true).count == 0
  end


  def self.being_delivering
    production_orders = ProductionOrder.where(delivering: true)
    if production_orders.count > 0
      return true
    end
    purchase_orders = PurchaseOrder.where(delivering: true)
    if purchase_orders.count > 0
      return true
    end
    vouchers = Voucher.where(delivering: true)
    if vouchers.count > 0
      return true
    end
    return false
  end

  def self.waiting_delivering
    production_orders = ProductionOrder.where(queued: true)
    if production_orders.count > 0
      return true
    end
    purchase_orders = PurchaseOrder.where(queued: true)
    if purchase_orders.count > 0
      return true
    end
    vouchers = Voucher.where(queued: true)
    if vouchers.count > 0
      return true
    end
    return false
  end

  def self.activate_queue

    to_deliver = nil
    global_type = nil

    if self.being_delivering
      current_delivery = nil
      type = nil
      production_orders = ProductionOrder.where(delivering: true)
      if production_orders.count > 0
        current_delivery = production_orders.first
        type = 'production_order'
      else
        purchase_orders = PurchaseOrder.where(delivering: true)
        if purchase_orders.count > 0
          current_delivery = purchase_orders.first
          type = 'purchase_order'
        else
          vouchers = Voucher.where(delivering: true)
          if vouchers.count > 0
            current_delivery = vouchers.first
            type = 'voucher'
          end
        end
      end
      to_deliver = current_delivery
      global_type = type
      #reactivar current_delivery
    end

    if not self.being_delivering and self.waiting_delivering
      next_delivery = nil
      type = nil
      production_orders = ProductionOrder.where(queued: true)
      if production_orders.count > 0
        next_delivery = production_orders.first
        type = 'production_order'
      else
        purchase_orders = PurchaseOrder.where(queued: true)
        if purchase_orders.count > 0
          next_delivery = purchase_orders.first
          type = 'purchase_order'

          #ftps = purchase_orders.where(group_number: -1)
          #if ftps.count > 0
          #  next_delivery = ftps.first
          #end

        else
          vouchers = Voucher.where(queued: true)
          if vouchers.count > 0
            next_delivery = vouchers.first
            type = 'voucher'
          end
        end
      end
      to_deliver = next_delivery
      global_type = type
      #mandar next_delivery
    end

    ok = false
    if global_type != nil
      to_deliver.delivering = true
      to_deliver.save!

      if global_type == "production_order"
        ok = Factory.mandar_op_despacho(to_deliver.id)
      elsif global_type == "purchase_order"
        distribuidor = (to_deliver.group_number == -1)
        ok = self.despachar_OC(to_deliver.id_cloud, distribuidor)
      elsif global_type == "voucher"
        ok = Production.deliver_order_to_address(to_deliver.id)
      end
    end

    if self.waiting_delivering and ok
      self.activate_queue
    end
    return "cola vacía"
  end


  #ordena los almacenes, dejando la mayoria en general
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
        #if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['despacho'])
        #  puts "Entro a Despacho -> General"
        #  for product_type in stock_despacho
        #    stock_despacho_sku = Production.get_stock(warehouses_id['despacho'], product_type['_id'])

        #    cant_a_mover = [stock_despacho_sku.length, moving_batch].min
        #    (0..cant_a_mover-1).to_a.each do |n|
        #      product_id = stock_despacho_sku[n]['_id']
        #      ret_code = Production.move_stock(warehouses_id['general'], product_id)
        #      puts "somethg moved D->G"
        #      request_counter += 1
        #    end
        #     request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
        #  end
        #  stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
        #  stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        #end

        # PREGENERAL -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['pregeneral'])
          puts "Entro a PREGENERAL -> GENERAL"
          for product_type in stock_pregeneral
            stock_pregeneral_sku = Production.get_stock(warehouses_id['pregeneral'], product_type['_id'])

            cant_a_mover = [stock_pregeneral_sku.length, moving_batch].min
            (0..cant_a_mover-1).to_a.each do |n|
              product_id = stock_pregeneral_sku[n]['_id']
              ret_code = Production.move_stock(warehouses_id['general'], product_id)
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
              ret_code = Production.move_stock(warehouses_id['general'], product_id)
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
              ret_code = Production.move_stock(warehouses_id['recepcion'], product_id)
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
        if _object != nil
          if _object["_id"] == sku
            count += _object["total"]
          end
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


# TODO J: Revisar y arreglar metodo
# FIXME J :test me
# chequea si hay que comprar mas de algun producto y manda a comprar el producto en particular
  def self.check_and_restore_stock
    warehouses_id = self.get_warehouses_id
    lista_de_productos = Product.where(owner: true).where(category: "Materia prima").or(Product.where(sku: '7'))
    cantidad_de_productos = lista_de_productos.length

    #ordenes de produccion
    production_orders = ProductionOrder.where("disponible > ?",Time.now)
    cantidad_deseada= {7 => 1500, 2 => 600,
                       6=> 500, 8 => 1600,
                       14=> 1700, 20=> 1600,
                       26=> 600, 39=> 600,
                       40=> 500, 41=> 800,
                       49=> 800}
    #cant_minima = 25% cant_deseada

    #cantidad_deseada = 25000/cantidad_de_productos
    #cantidad_minima = 15000/cantidad_de_productos

    for producto in lista_de_productos
      sku = producto['sku']
      stock_actual = producto.stock_disponible 
      puts "stock actual de #{sku} = #{stock_actual}"
      # incluir ordenes de produccion pendientes
      for production_order in production_orders
        if production_order['product_sku'] == sku
          stock_actual += production_order['cantidad']
        end
      end
      puts "stock actual contando ordenes de produccion de #{sku} = #{stock_actual}"

      if stock_actual < 400
        puts "Reponer!"
        cantidad_por_comprar = cantidad_deseada[sku.to_i] - stock_actual
        resp = RawMaterial.restore_stock(sku, cantidad_por_comprar) #FIXME quizas agregar to_i
        puts "Restore_stock #{producto.description} responde: #{resp}"
      end

    end
  end


  def self.move_A_B(_B, _A, _Q)
    puts "move"
    puts _B
    puts _A
    puts _Q.to_s

    sleep_time = 6
    max_request_counter = 50
    moving_batch = 40
    warehouses_id = self.get_warehouses_id

    stock_general = Production.get_all_stock_warehouse(warehouses_id[_A])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id[_B])
    request_counter = 0

    counter = 0

    Rails.application.config.able_to_reorder = true
    while Rails.application.config.able_to_reorder and counter < _Q#Crear boton que permita parar esto #self.puede_reordenar_ok
      puts "\n \nIteracion:"
      puts "General: #{stock_general}"
      puts "Despacho: #{stock_despacho}"

      if stock_despacho.length == 0
        puts "Nada en #{_B}!"
        return true
      elsif self.full_warehouse(warehouses_id[_A])
        puts "Se llenaron las bodegas #{_A}"
        return true
      else
        # DESPACHO -> GENERAL
        if !self.full_warehouse(warehouses_id[_A]) and !self.empty_warehouse(warehouses_id[_B])
          puts "Entro a #{_A} -> #{_B}"
          for product_type in stock_despacho
            if counter < _Q
              stock_despacho_sku = Production.get_stock(warehouses_id[_B], product_type['_id'])

              cant_a_mover = [stock_despacho_sku.length, moving_batch].min
              (0..cant_a_mover-1).to_a.each do |n|
                product_id = stock_despacho_sku[n]['_id']
                if counter < _Q
                  counter += 1
                  ret_code = Production.move_stock(warehouses_id[_A], product_id)
                  puts "somethg moved Desp->Gen"
                  request_counter += 1
                else
                  break
                end
              end
               request_counter = Tiempo.sleep_if_to_many_requests(request_counter, max_request_counter, sleep_time)
            else
              break
            end
          end
          stock_despacho = Production.get_all_stock_warehouse(warehouses_id[_B])
          stock_general = Production.get_all_stock_warehouse(warehouses_id[_A])
        end
      end
      puts "\n \nAble_to_order: #{Rails.application.config.able_to_reorder}"
    end

  end


  def self.move_despacho_general
    self.move_A_B('despacho', 'general', 10000000000)
  end


  def self.move_recepcion_general
    self.move_A_B('recepcion', 'general', 10000000000)
  end




end
