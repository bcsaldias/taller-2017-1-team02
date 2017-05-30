Deface::Override.new(virtual_path: 'spree/products/show',
  name: 'add_sku_to_product_view',
  insert_after: "[data-hook='cart_form']",
  text: "<h4><%= 'Stock disponible: ' + @product.stock.to_s %></h4>")