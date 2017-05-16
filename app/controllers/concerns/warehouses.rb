
module Warehouses
  include Production
  include Factory

#retorna los id de cada warehouse en forma de diccionario
  def get_warehouses_id
    warehouses_id = {}
    warehouses = Production.get_warehouses

    for warehouse in warehouses
      if warehouse['pulmon']
        warehouses_id['pulmon'] = warehouse['id']
      elsif warehouse['despacho']
        warehouses_id['despacho'] = warehouse['id']
      elsif warehouse['recepcion']
        warehouses_id['recepcion'] = warehouse['id']
      else
        warehouses_id['general'] = warehouse['id']
      end

    return warehouses_id
  end

#retorna el stock de cierto sku para cada warehouse en forma de diccionario
  def get_warehouses_stock(sku)
    warehouses_stock = {}
    warehouses_id = get_warehouses_id
    warehouses_stock['pulmon'] = Production.get_stock(warehouses_id['pulmon'], sku)
    warehouses_stock['despacho'] = Production.get_stock(warehouses_id['despacho'], sku)
    warehouses_stock['recepcion'] = Production.get_stock(warehouses_id['recepcion'], sku)
    warehouses_stock['general'] = Production.get_stock(warehouses_id['general'], sku)
    return warehouses_stock
  end

#retorna el espacio libre de cada warehouse en forma de diccionario
  def get_warehouses_space
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

    return warehouses_id
  end

    #preparar bodega para despachar
    #retorna true si queda lista, un int indicando cuantos productos del sku deja en la bodega de despacho
  def get_despacho_ready(sku, q_a_despachar)
    warehouses_id = get_warehouses_id
    stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)

    while q_a_despachar > stock_despacho.length
      stock_general = Production.get_stock(warehouses_id['general'], sku)
      stock_recepcion = Production.get_stock(warehouses_id['recepcion'], sku)
      stock_pulmon = Production.get_stock(warehouses_id['pulmon'], sku)

      if (stock_general.length == 0 and stock_recepcion.length == 0 and stock_pulmon.length == 0)
        break
      else
        for product in stock_general
          Production.move_stock(warehouses_id['despacho'], product['id'])
        end
        for product in stock_recepcion
          Production.move_stock(warehouses_id['recepcion'], product['id'])
        end
        for product in stock_pulmon
          Production.move_stock(warehouses_id['pulmon'], product['id'])
        end
      end
    end

    stock_despacho = Production.get_stock(warehouses_id['despacho'], sku)
    if  q_a_despachar <= stock_despacho.length
      return true
    else
      return stock_despacho.length
    end
  end

def check_stock_and_restore_stock
  # Revisa el stock de cada sku, si algun sku tiene menos productos que la
  # cantidad minima, los repone con llamadas a RawMaterial.restore_stock(sku, quantity)
end
