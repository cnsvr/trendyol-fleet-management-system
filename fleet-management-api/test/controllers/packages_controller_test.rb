# frozen_string_literal: true

require 'test_helper'

class PackagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @package = packages(:one)
    @bag = bags(:one)
  end

  test 'should get index' do
    get packages_url, as: :json
    assert_response :success
  end

  test 'should create package' do
    assert_difference('Package.count') do
      post packages_url, params: { package: { barcode: 'AD200', delivery_point_id: 1, volumetric_weight: @package.volumetric_weight } }, as: :json
    end
    
    assert_response 201
  end

  test 'should render errors if package is not created' do
    assert_no_difference('Package.count') do
      post packages_url, params: { package: { delivery_point_id: 1, volumetric_weight: @package.volumetric_weight } }, as: :json
    end

    assert_response 422
    assert_equal "can't be blank", JSON.parse(response.body)['barcode'].first
  end

  test 'should show package' do
    get package_url(@package), as: :json
    assert_response :success
  end

  test 'should update package' do
    patch package_url(@package),
          params: { package: { bag: @package.bag, barcode: @package.barcode, delivery_point: @package.delivery_point, state: @package.state, volumetric_weight: @package.volumetric_weight } }, as: :json
    assert_response 200
  end

  test 'should render errors if package is not updated' do
    patch package_url(@package),
          params: { package: { barcode: 'AC101', delivery_point_id: @package.delivery_point.id, volumetric_weight: @package.volumetric_weight } }, as: :json
          
    assert_response 422
    assert_equal 'has already been taken', JSON.parse(response.body)['barcode'].first
  end

  test 'should destroy package' do
    assert_difference('Package.count', -1) do
      delete package_url(@package), as: :json
    end

    assert_response 204
  end

  test 'should add package to bag' do
    post add_package_to_bag_url,
          params: { add_package_to_bag: { barcode: @package.barcode, bag_barcode: @bag.barcode } }, as: :json
    
    assert_response 200
    assert_equal @bag.id, @package.reload.bag_id
    assert_equal 2, @package.state

    assert_equal @package.barcode, JSON.parse(response.body)['barcode']
    assert_equal @bag.barcode,  JSON.parse(response.body)['bag']['barcode']
  end

  test 'should return error if package is not found' do
    post add_package_to_bag_url,
          params: { add_package_to_bag: { barcode: 'AC102', bag_barcode: @bag.barcode } }, as: :json
    
    assert_response 404
    assert_equal 'Package not found', JSON.parse(response.body)['error']
  end

  test 'should return error if bag is not found' do
    post add_package_to_bag_url,
          params: { add_package_to_bag: { barcode: @package.barcode, bag_barcode: 'A102' } }, as: :json
    
    assert_response 404
    assert_equal 'Bag not found', JSON.parse(response.body)['error']
  end

  test 'should return error if package and bag are not in the same delivery point' do
    delivery_point = DeliveryPoint.create!(delivery_point: 'Transfer Center', value: 3)
    @bag.update!(delivery_point: delivery_point)
    
    post add_package_to_bag_url,
          params: { add_package_to_bag: { barcode: @package.barcode, bag_barcode: @bag.barcode } }, as: :json
    
    assert_response 422
    assert_equal 'Package and bag must be in the same delivery point', JSON.parse(response.body)['error']
  end
end
