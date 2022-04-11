require "test_helper"

class DeliveryPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @delivery_point = DeliveryPoint.last
  end

  test "should get index" do
    get delivery_points_url, as: :json
    assert_response :success
  end

  # test "should create delivery_point" do
  #   assert_difference('DeliveryPoint.count') do
  #     post delivery_points_url, params: { delivery_point: { delivery_point: 'Transfer Cente', value: 3 } }, as: :json
  #   end

  #   assert_response 201
  # end

  test "should show delivery_point" do
    get delivery_point_url(@delivery_point), as: :json
    assert_response :success
  end

  # test "should update delivery_point" do
  #   patch delivery_point_url(@delivery_point), params: { delivery_point: { delivery_point: @delivery_point.delivery_point, value: @delivery_point.value } }, as: :json
  #   assert_response 200
  # end

  test "should destroy delivery_point" do
    assert_difference('DeliveryPoint.count', -1) do
      delete delivery_point_url(@delivery_point), as: :json
    end

    assert_response 204
  end
end
