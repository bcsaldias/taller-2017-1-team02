'_id'
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
    if general_1_cap > general_2_cap
      warehouses_id['general'] = general_1
      warehouses_id['pregeneral'] = general_2
    else
      warehouses_id['general'] = general_2
      warehouses_id['pregeneral'] = general_1
    end

    return warehouses_id
  end

#retorna el stock de cierto sku para cada warehouse en forma de diccionario
  def self.get_warehouses_stock(sku)
    warehouses_stock = {}
    warehouses_id = self.get_warehouses_id
    warehouses_stock['pulmon'] = Production.get_stock(warehouses_id['pulmon'], sku)
    warehouses_stock['despacho'] = Production.get_stock(warehouses_id['despacho'], sku)
    warehouses_stock['recepcion'] = Production.get_stock(warehouses_id['recepcion'], sku)
    warehouses_stock['general'] = Production.get_stock(warehouses_id['general'], sku)
    return warehouses_stock
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

    while q_a_despachar > cantidad_en_despacho
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
            sleep(20)
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
            sleep(20)
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
            sleep(20)
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
            sleep(20)
          end
        end
      end
    end

    puts "termina while"
    stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)
    if  q_a_despachar <= stock_despacho.length
      return true
    else
      return false
    end
  end

#despachar_OC despacha las ordenes de compra
  def self.despachar_OC(id_cloud_OC)
   warehouses_id = self.get_warehouses_id
   purchase_order = Sales.get_purchase_order(id_cloud_OC)
   sku = purchase_order['sku']
   cantidad = purchase_order['cantidad'] ######################################
   stock_a_despachar = Production.get_stock(warehouses_id)

   get_despacho_ready

   for product in stock_a_despachar
     Production.move_stock_external(warehouse_id, product_id, purchase_order, price) ###############parametrizar####
     cantidad -= 1
     if cantidad == 0
       break
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
    warehouses_id = self.get_warehouses_id
    puts warehouses_id['general']
    stock_general = Production.get_all_stock_warehouse(warehouses_id['general'])
    stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
    stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
    stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
    stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
    contador_de_requests = 0

    while stock_general.length > 0
      if stock_despacho.length == 0 and stock_pregeneral.length == 0 and stock_recepcion.length == 0 and stock_pulmon.length == 0
        return true
        break
      else
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['despacho'])
          for product_type in stock_despacho
            stock_despacho_sku = Production.get_stock(warehouses_id['despacho'], product_type['_id'])
            puts stock_despacho_sku[0]
            product_id = stock_despacho_sku[0]['_id']
            Production.move_stock(warehouses_id['general'], product_id)
            puts "smthg moved"
          end
          contador_de_requests += stock_despacho.length
          stock_despacho = Production.get_all_stock_warehouse(warehouses_id['despacho'])
        end
        if contador_de_requests > 20
          sleep(20)
          contador_de_requests = 0
        end
        if !self.full_warehouse(warehouses_id['general']) and !self.empty_warehouse(warehouses_id['pregeneral'])
          for product_type in stock_pregeneral
            stock_despacho_sku = Production.get_stock(warehouses_id['pregeneral'], product_type['_id'])
            product_id = stock_despacho_sku[0]['_id']
            Production.move_stock(warehouses_id['general'], product_id)
          end
          contador_de_requests += stock_pregeneral.length
          stock_pregeneral = Production.get_all_stock_warehouse(warehouses_id['pregeneral'])
        end
        if contador_de_requests > 20
          sleep(20)
          contador_de_requests = 0
        end
        if !self.full_warehouse(warehouses_id['pregeneral']) and !self.empty_warehouse(warehouses_id['recepcion'])
          for product_type in stock_recepcion
            stock_recepcion_sku = Production.get_stock(warehouses_id['recepcion'], product_type['_id'])
            product_id = stock_recepcion_sku[0]['_id']
            Production.move_stock(warehouses_id['pregeneral'], product_id)
          end
          contador_de_requests += stock_recepcion.length
          stock_recepcion = Production.get_all_stock_warehouse(warehouses_id['recepcion'])
        end
        if contador_de_requests > 20
          sleep(20)
          contador_de_requests = 0
        end
        if !self.full_warehouse(warehouses_id['recepcion']) and !self.empty_warehouse(warehouses_id['pulmon'])
          for product_type in stock_pulmon
            stock_pulmon_sku = Production.get_stock(warehouses_id['pulmon'], product_type['_id'])
            product_id = stock_pulmon_sku[0]['_id']
            Production.move_stock(warehouses_id['recepcion'], product_id)
          end
          contador_de_requests += stock_pulmon.length
          stock_pulmon = Production.get_all_stock_warehouse(warehouses_id['pulmon'])
        end
        if contador_de_requests > 20
          sleep(20)
          contador_de_requests = 0
        end
      end
    end
    return false
  end
  ##get all stock, me entrega por sku??? osea los puedo ir a buscar de a uno?


#metodo que evalua si podemos vender q_asked de cierto sku
  def self.able_to_sale(sku, q_asked)
    # purchase_order = Sales.get_purchase_order(id OC)
    # needs_production = products(sku).stock - purchase_order.cantidad
    # producing_on_time = 0
    # if needs_production >= 0
    #   return aceptada
    # else
    #   for OC in purchase_orders
    #     if !OC.owner
    #       i = Sales.get_purchase_order(OC.id_cloud)
    #       if i.sku = purchase_order.sku and i.fecha_entrega < purchase_order.fecha_entrega and i.accepted and !i.reservado
    #         producing += i.cantidad
    #       end
    #     end
    #   end
    # end
    # if producing_on_time > needs_production
    #   return aceptada
    # else
    #   return rechazada
    # end
  end

end
