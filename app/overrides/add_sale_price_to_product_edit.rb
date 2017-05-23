#Deface::Override.new(virtual_path: 'spree/admin/products/_form',
#  name: 'add_sale_price_to_product_edit',
#  insert_after: "erb[loud]:contains('text_field :price')",
#  text: "
#    <%= f.field_container :sale_price do %>
#      <%= f.label :sale_price, raw(Spree.t(:sale_price) + content_tag(:span, ' *')) %>
#      <%= f.text_field :sale_price, value:
#        number_to_currency(@product.price, unit: '') %>
#      <%= f.error_message_on :sale_price %>
#    <% end %>
#  ")