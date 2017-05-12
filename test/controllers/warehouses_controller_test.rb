require 'test_helper'

class WarehousesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @warehouse = warehouses(:one)
  end

  test "should get index" do
    get warehouses_url, as: :json
    assert_response :success
  end

  test "should create warehouse" do
    assert_difference('Warehouse.count') do
      post warehouses_url, params: { warehouse: { id_cloud: @warehouse.id_cloud } }, as: :json
    end

    assert_response 201
  end

  test "should show warehouse" do
    get warehouse_url(@warehouse), as: :json
    assert_response :success
  end

  test "should update warehouse" do
    patch warehouse_url(@warehouse), params: { warehouse: { id_cloud: @warehouse.id_cloud } }, as: :json
    assert_response 200
  end

  test "should destroy warehouse" do
    assert_difference('Warehouse.count', -1) do
      delete warehouse_url(@warehouse), as: :json
    end

    assert_response 204
  end
end
