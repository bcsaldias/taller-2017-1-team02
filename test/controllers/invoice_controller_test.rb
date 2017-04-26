require 'test_helper'

class InvoiceControllerTest < ActionDispatch::IntegrationTest
  test "should get enviar_confirmacion_factura" do
    get invoice_enviar_confirmacion_factura_url
    assert_response :success
  end

  test "should get enviar_rechazo_factura" do
    get invoice_enviar_rechazo_factura_url
    assert_response :success
  end

  test "should get enviar_confirmacion_pago" do
    get invoice_enviar_confirmacion_pago_url
    assert_response :success
  end

  test "should get enviar_factura" do
    get invoice_enviar_factura_url
    assert_response :success
  end

  test "should get notificar_orden_despachada" do
    get invoice_notificar_orden_despachada_url
    assert_response :success
  end

end
