Deface::Override.new(virtual_path: 'spree/products/show',
  name: 'add_sku_to_product_view',
  insert_after: "[data-hook='cart_form']",
  text: "<h4><%= 'Stock disponible: ' + @product.total_on_hand.to_s %></h4>")

Deface::Override.new(virtual_path: 'spree/products/show',
  name: 'drop_promotions_from_product_view',
  replace: "[data-hook='promotions']",
  text: "")

Deface::Override.new(virtual_path: 'spree/checkout/_payment',
  name: 'drop_coupon_from_product_view',
  replace: "[data-hook='coupon_code']",
  text: "")



