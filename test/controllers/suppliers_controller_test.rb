require 'test_helper'

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  test "should get informar_cuenta_banco" do
    get suppliers_informar_cuenta_banco_url
    assert_response :success
  end

end
