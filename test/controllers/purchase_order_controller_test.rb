require 'test_helper'

class PurchaseOrderControllerTest < ActionDispatch::IntegrationTest
  test "should get realizar_pedido" do
    get purchase_order_realizar_pedido_url
    assert_response :success
  end

  test "should get responder_orden_compra" do
    get purchase_order_responder_orden_compra_url
    assert_response :success
  end

end
