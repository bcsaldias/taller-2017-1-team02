require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:one)
  end

  test "should get index" do
    get contacts_url, as: :json
    assert_response :success
  end

  test "should create contact" do
    assert_difference('Contact.count') do
      post contacts_url, params: { contact: { expected_production_time: @contact.expected_production_time, min_production_batch: @contact.min_production_batch, priority: @contact.priority, product: @contact.product, production_unit_cost: @contact.production_unit_cost, supplier: @contact.supplier } }, as: :json
    end

    assert_response 201
  end

  test "should show contact" do
    get contact_url(@contact), as: :json
    assert_response :success
  end

  test "should update contact" do
    patch contact_url(@contact), params: { contact: { expected_production_time: @contact.expected_production_time, min_production_batch: @contact.min_production_batch, priority: @contact.priority, product: @contact.product, production_unit_cost: @contact.production_unit_cost, supplier: @contact.supplier } }, as: :json
    assert_response 200
  end

  test "should destroy contact" do
    assert_difference('Contact.count', -1) do
      delete contact_url(@contact), as: :json
    end

    assert_response 204
  end
end
