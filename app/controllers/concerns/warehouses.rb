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


    #preparar bodega para despachar
    #retorna true si queda lista, un int indicando cuantos productos del sku deja en la bodega de despacho
  def self.get_despacho_ready(sku, q_a_despachar)
    warehouses_id = self.get_warehouses_id
    stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)
    cantidad_en_despacho = stock_despacho.length
    a = [1,2,4]
    contador_de_requests = 0

    puts "q_a_despachar"
    puts q_a_despachar
    puts "q_en_despacho"
    puts cantidad_en_despacho
    while q_a_despachar > cantidad_en_despacho
      puts "cantidad_en_despacho: #{cantidad_en_despacho}"
      stock_general = Production.get_stock(warehouses_id['general'], sku)
      stock_pregeneral = Production.get_stock(warehouses_id['pregeneral'],sku)
      stock_recepcion = Production.get_stock(warehouses_id['recepcion'], sku)
      stock_pulmon = Production.get_stock(warehouses_id['pulmon'], sku)
      puts "comienza while"
      if (stock_general.length == 0 and stock_recepcion.length == 0 and stock_pulmon.length == 0 and stock_pregeneral == 0)
        break
      else
        for product in stock_general
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['despacho'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > 19
            contador_de_requests = 0
            sleep(15)
          end
          cantidad_en_despacho += 1
          #puts "general a despacho"
        end
        for product in stock_pregeneral
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['general'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > 19
            contador_de_requests = 0
            sleep(15)
          end
          #puts "pregeneral a general"
        end
        for product in stock_recepcion
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['pregeneral'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > 19
            contador_de_requests = 0
            sleep(15)
          end
          #puts "recepcion a pregeneral"
        end
        for product in stock_pulmon
          if cantidad_en_despacho >= q_a_despachar
            break
          end
          Production.move_stock(warehouses_id['recepcion'], product['_id'])
          contador_de_requests +=1
          if contador_de_requests > 19
            contador_de_requests = 0
            sleep(15)
          end
        end
      end
    end

    puts "termina while"
    puts sku
    stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)
    puts stock_despacho
    puts "return"
    if  q_a_despachar <= stock_despacho.length
      puts "get_despacho_ready: Productos listos en despacho!"
      return true
    else
      puts "get_despacho_ready: No fue posible poner todos los productos necesarios en bodega"
      return false
    end
  end

#despachar_OC despacha las ordenes de compra
  def self.despachar_OC(id_cloud_OC)
    purchase_order = Sales.get_purchase_order(id_cloud_OC)
    our_purchase_order = PurchaseOrder.where(id_cloud: id_cloud_OC).first

    puts purchase_order
    puts purchase_order["sku"], purchase_order["cantidad"]

    ret = self.get_despacho_ready(purchase_order["sku"], purchase_order["cantidad"].to_i)
    puts "ret", ret
    price = purchase_order['precioUnitario']
    puts("price",price)
    q_to_send = purchase_order['cantidad']
    puts("q_to_send",q_to_send)

    purchase_order_from_table = PurchaseOrder.where(id_cloud: id_cloud_OC).first
    puts "purchase_order_from_table", purchase_order_from_table
    client_warehouse = purchase_order_from_table['id_store_reception']
    puts "client_warehouse", client_warehouse

    warehouses_id = self.get_warehouses_id
    stock_a_despachar = Production.get_stock(warehouses_id['despacho'], purchase_order["sku"])


    puts "stock_a_despachar"
    puts stock_a_despachar
    puts "stock_a_despachar"

    for product in stock_a_despachar
      puts "DESPACHAR"
      puts product
      ret = Production.move_stock_external(client_warehouse, produ=product['_id'],
                                            id_cloud_OC, price)
      puts "ret2"
      puts ret
      if ret.code == 200 or ret.code == 201
        q_to_send -= 1
        if q_to_send == 0
          our_purchase_order.state = 3
          our_purchase_order.save
          return true
          break
        end
      else
        return false
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
  def self.sort_warehouses
    sleep_time = 20
    puts "starting reorder"
    warehouses_id = self.get_warehouses_id
    # puts warehouses_id['general']
    stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
    stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
    request_counter = 0

    while true
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

            if stock_despacho_sku.length >= 10
              (0..9).to_a.each do |n|
                product_id = stock_despacho_sku[n]['_id']
                Production.move_stock(warehouses_id['general'], product_id)
                puts "somethg moved"
                request_counter += 1
              end
            else
              product_id = stock_despacho_sku[0]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved"
              request_counter += 1
             end
             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, 20, sleep_time)

          end
          stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end
        # if request_counter > 20
        #   sleep(sleep_time)
        #   request_counter = 0
        # end

        # PREGENERAL -> GENERAL
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['pregeneral'])
          puts "Entro a PREGENERAL -> GENERAL"
          for product_type in stock_pregeneral
            stock_pregeneral_sku = Production.get_stock(warehouses_id['pregeneral'], product_type['_id'])

            if stock_pregeneral_sku.length >= 10
              (0..9).to_a.each do |n|
                product_id = stock_pregeneral_sku[n]['_id']
                Production.move_stock(warehouses_id['general'], product_id)
                puts "somethg moved"
                request_counter += 1
              end
            else
              product_id = stock_pregeneral_sku[0]['_id']
              Production.move_stock(warehouses_id['general'], product_id)
              puts "somethg moved"
              request_counter += 1
            end
            request_counter = Tiempo.sleep_if_to_many_requests(request_counter, 20, sleep_time)
          end
          stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
          stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        end
        # if request_counter > 20
        #   sleep(sleep_time)
        #   request_counter = 0
        # end

        # RECEPCION -> PREGENERAL
        if !self.full_warehouse(warehouses_id['pregeneral']) and !self.empty_warehouse(warehouses_id['recepcion'])
          puts "Entro a RECEPCION -> PREGENERAL"
          for product_type in stock_recepcion
            stock_recepcion_sku = Production.get_stock(warehouses_id['recepcion'], product_type['_id'])

            if stock_recepcion_sku.length >= 10
              (0..9).to_a.each do |n|
                product_id = stock_recepcion_sku[n]['_id']
                Production.move_stock(warehouses_id['pregeneral'], product_id)
                puts "somethg moved"
                request_counter += 1
              end
            else
              product_id = stock_recepcion_sku[0]['_id']
              Production.move_stock(warehouses_id['pregeneral'], product_id)
              puts "somethg moved"
              request_counter += 1
             end
             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, 20, sleep_time)
          end
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
          stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
        end
        # if request_counter > 20
        #   sleep(sleep_time)
        #   request_counter = 0
        # end

        # PULMON -> RECEPCION
        if !self.full_warehouse(warehouses_id['recepcion']) and !self.empty_warehouse(warehouses_id['pulmon'])
          puts "Entro a PULMON -> RECEPCION"
          for product_type in stock_pulmon
            stock_pulmon_sku = Production.get_stock(warehouses_id['pulmon'], product_type['_id'])

            if stock_pulmon_sku.length >= 10
              (0..9).to_a.each do |n|
                product_id = stock_pulmon_sku[n]['_id']
                Production.move_stock(warehouses_id['recepcion'], product_id)
                puts "somethg moved"
                request_counter += 1
              end
            else
              product_id = stock_pulmon_sku[0]['_id']
              Production.move_stock(warehouses_id['recepcion'], product_id)
              puts "somethg moved"
              request_counter += 1
             end
             request_counter = Tiempo.sleep_if_to_many_requests(request_counter, 20, sleep_time)
          end
          stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
        end
        # if request_counter > 20
        #   sleep(sleep_time)
        #   request_counter = 0
        # end
      end
    end

    puts "No Ordenado, retorno false"
    return false
  end


 def self.product_stock(sku)
        warehouses_id = self.get_warehouses_id

        count = 0
        stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
        for _object in stock_general
          if _object["_id"] == sku
            count += _object["total"]
          end
        end

        stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
        for _object in stock_pregeneral
          if _object["_id"] == sku
            count += _object["total"]
          end
        end

        stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
        for _object in stock_recepcion
          if _object["_id"] == sku
            count += _object["total"]
          end
        end

        stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
        for _object in stock_pulmon
          if _object["_id"] == sku
            count += _object["total"]
          end
        end

        return count
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
end
