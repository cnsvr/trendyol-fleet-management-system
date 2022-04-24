# frozen_string_literal: true

require 'test_helper'

class VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vehicle = vehicles(:one)
    @delivery_point_one = delivery_points(:one)
    @delivery_point_two = delivery_points(:two)
  end

  test 'should get index' do
    get vehicles_url, as: :json
    assert_response :success
  end

  test 'should create vehicle' do
    assert_difference('Vehicle.count') do
      post vehicles_url, params: { vehicle: { plate: '34 TT 100' } }, as: :json
    end

    assert_response 201
  end

  test 'should render errors if vehicle is not created' do
    assert_no_difference('Vehicle.count') do
      post vehicles_url, params: { vehicle: { plate: '' } }, as: :json
    end

    assert_response 422
    assert_equal 'can\'t be blank', JSON.parse(response.body)['plate'].first
  end

  test 'should show vehicle' do
    get vehicle_url(@vehicle), as: :json
    assert_response :success
  end

  test 'should update vehicle' do
    patch vehicle_url(@vehicle), params: { vehicle: { plate: @vehicle.plate } }, as: :json
    assert_response 200
  end

  test 'should render errors if vehicle is not updated' do
    patch vehicle_url(@vehicle), params: { vehicle: { plate: '67 VA 510' } }, as: :json

    assert_response 422
    assert_equal 'has already been taken', JSON.parse(response.body)['plate'].first
  end

  test 'should destroy vehicle' do
    assert_difference('Vehicle.count', -1) do
      delete vehicle_url(@vehicle), as: :json
    end

    assert_response 204
  end

  test 'should return ParameterMissing error if plate is not provided' do
    assert_no_difference('Vehicle.count') do
      post vehicles_url, params: { vehicle: { } }, as: :json
    end
    
    assert_response 400
    assert_equal 'param is missing or the value is empty: vehicle', JSON.parse(response.body)['error']
  end

  context 'load and unload shipments' do
    test 'should return error if vehicle is not found' do
      post load_and_unload_shipments_url, params: { plate: '34 TT 100', route: [{ deliveryPoint: 1, deliveries: [{ barcode: '1234567890123' }] }] }, as: :json
    
      assert_response 404
      assert_equal 'Vehicle not found', JSON.parse(response.body)['error']
    end

    test 'should return error if delivery point is not found' do
      
      post load_and_unload_shipments_url, params: { plate: @vehicle.plate, route: [{ deliveryPoint: 10, deliveries: [{ barcode: '1234567890123' }] }] }, as: :json
      

      assert_response 404
      assert_equal 'Delivery Point not found', JSON.parse(response.body)['error']
    end

    test 'should remain as created if there is no shipments to load' do
      package = Package.create!(barcode: 'P8988000120', delivery_point: @delivery_point_one, volumetric_weight: 10)

      post load_and_unload_shipments_url, params: { plate: @vehicle.plate, route: [{ deliveryPoint: @delivery_point_one.id, deliveries: [ { barcode: 'random-barcode' }] }] }, as: :json

      assert_response 200
      assert_equal 1, package.reload.state
    end

    test 'should load and not unload shipments due to attempt to deliver to the wrong point' do
      bag = Bag.create!(barcode: 'C725799', delivery_point: @delivery_point_two)
      package = Package.create!(barcode: 'P8988000121', delivery_point: @delivery_point_two, volumetric_weight: 10)

      assert_equal 1, bag.state
      assert_equal 1, package.state

      post load_and_unload_shipments_url, params: { plate: @vehicle.plate, route: [{ deliveryPoint: @delivery_point_one.id, deliveries: [{ barcode: 'C725799' }, { barcode: 'P8988000121' }] }] }, as: :json

      assert_response 200

      assert_equal 'C725799', JSON.parse(response.body)['route'].first['deliveries'].first['barcode']
      assert_equal 3,  JSON.parse(response.body)['route'].first['deliveries'].first['state']
      assert_equal 3, bag.reload.state

      assert_equal 'P8988000121', JSON.parse(response.body)['route'].first['deliveries'].last['barcode']
      assert_equal 3,  JSON.parse(response.body)['route'].first['deliveries'].last['state']
      assert_equal 3, package.reload.state
    end

    test 'should load and not unload shipments' do
      bag = Bag.create!(barcode: 'XYZ100', delivery_point: @delivery_point_two)
      package = Package.create!(barcode: 'XYZ200', delivery_point: @delivery_point_one, volumetric_weight: 10)

      assert_equal 1, bag.state
      assert_equal 1, package.state

      post load_and_unload_shipments_url, params: { plate: @vehicle.plate, route: [{ deliveryPoint: @delivery_point_one.id, deliveries: [{ barcode: 'XYZ100' }, { barcode: 'XYZ200' }] }] }, as: :json

      assert_response 200

      assert_equal 'XYZ100', JSON.parse(response.body)['route'].first['deliveries'].first['barcode']
      assert_equal 3,  JSON.parse(response.body)['route'].first['deliveries'].first['state']
      assert_equal 3, bag.reload.state

      assert_equal 'XYZ200', JSON.parse(response.body)['route'].first['deliveries'].last['barcode']
      assert_equal 4,  JSON.parse(response.body)['route'].first['deliveries'].last['state']
      assert_equal 4, package.reload.state
    end

    test 'should load and unload bag and package shipments' do
      bag = Bag.create!(barcode: 'C725800', delivery_point: @delivery_point_two)
      package = Package.create!(barcode: 'P8988000122', delivery_point: @delivery_point_two, volumetric_weight: 10)
      package_two = Package.create!(barcode: 'P8988000126', delivery_point: @delivery_point_two, volumetric_weight: 10)

      assert_equal 1, bag.state
      assert_equal 1, package.state

      post load_and_unload_shipments_url, params: { plate: @vehicle.plate, route: [{ deliveryPoint: @delivery_point_two.id, deliveries: [{ barcode: 'C725800' }, { barcode: 'P8988000122' }, { barcode: 'P8988000126'}] }] }, as: :json
    

      assert_response 200

      assert_equal 'C725800', JSON.parse(response.body)['route'].first['deliveries'].first['barcode']
      assert_equal 4,  JSON.parse(response.body)['route'].first['deliveries'].first['state']
      assert_equal 4, bag.reload.state

      assert_equal 'P8988000122', JSON.parse(response.body)['route'].first['deliveries'].second['barcode']
      assert_equal 4,  JSON.parse(response.body)['route'].first['deliveries'].second['state']
      assert_equal 4, package.reload.state

      assert_equal 'P8988000126', JSON.parse(response.body)['route'].first['deliveries'].last['barcode']
      assert_equal 4,  JSON.parse(response.body)['route'].first['deliveries'].last['state']
      assert_equal 4, package_two.reload.state
    end
  end
end
