require "test_helper"

class DeliveryPointTest < ActiveSupport::TestCase
  test 'should not save delivery point without delivery point and value' do
    delivery_point = DeliveryPoint.new
    
    assert_not delivery_point.save, "Saved the delivery point without a delivery point and value"
  end

  test 'should not save delivery point with invalid delivery point' do
    delivery_point = DeliveryPoint.new(delivery_point: 'Invalid Point')
    
    assert_not delivery_point.save, "Saved the delivery point with an invalid delivery point"
  end

  test 'should save delivery point with valid delivery point and value' do
    delivery_point = DeliveryPoint.new(delivery_point: 'Transfer Center', value: 3)
    
    assert delivery_point.save, "Saved the delivery point with a valid delivery point"
  end

  test 'could have any bags' do
    delivery_point = DeliveryPoint.new(delivery_point: 'Transfer Center', value: 3)
    bag = Bag.new(delivery_point: delivery_point, barcode: 'AB102')
    delivery_point.save!
    
    assert_not_nil delivery_point.bags, "Delivery point does not have any bags"
  end

  test 'could have any packages' do
    delivery_point = DeliveryPoint.new(delivery_point: 'Transfer Center', value: 3)
    bag = Package.new(delivery_point: delivery_point, barcode: 'AC102', volumetric_weight: 2)
    delivery_point.save!
    
    assert_not_nil delivery_point.bags, "Delivery point does not have any packages"
  end
end
