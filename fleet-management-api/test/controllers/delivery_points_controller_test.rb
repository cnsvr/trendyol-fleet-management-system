# frozen_string_literal: true

require 'test_helper'

class DeliveryPointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @delivery_point = delivery_points(:two)
  end

  test 'should get index' do
    get delivery_points_url, as: :json
    assert_response :success
  end

  test 'should create delivery_point' do
    assert_difference('DeliveryPoint.count') do
      post delivery_points_url, params: { delivery_point: { delivery_point: 'Transfer Center', value: 3 } }, as: :json
    end

    assert_response 201
  end

  test 'should render errors if delivery_point is not created' do
    assert_no_difference('DeliveryPoint.count') do
      post delivery_points_url, params: { delivery_point: { delivery_point: 'Unknown Center' } }, as: :json
    end

    assert_response 422
    assert_equal 'Unknown Center is not a valid delivery point. It has to be one of Branch,Distribution Center,Transfer Center',
                 JSON.parse(response.body)['delivery_point'].first
  end

  test 'should show delivery_point' do
    get delivery_point_url(@delivery_point), as: :json
    assert_response :success
  end

  test 'should update delivery_point' do
    patch delivery_point_url(@delivery_point),
          params: { delivery_point: { delivery_point: @delivery_point.delivery_point, value: @delivery_point.value } }, as: :json
    assert_response 200
  end

  test 'should render errors if delivery_point is not updated' do
    patch delivery_point_url(@delivery_point),
          params: { delivery_point: { delivery_point: 'Unknown Center' }, value: 4 }, as: :json

    assert_response 422
    assert_equal 'Unknown Center is not a valid delivery point. It has to be one of Branch,Distribution Center,Transfer Center',
                  JSON.parse(response.body)['delivery_point'].first
  end

  test 'should destroy delivery_point' do
    assert_difference('DeliveryPoint.count', -1) do
      delete delivery_point_url(@delivery_point), as: :json
    end

    assert_response 204
  end
end
