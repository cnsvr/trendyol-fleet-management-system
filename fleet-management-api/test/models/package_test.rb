# frozen_string_literal: true

require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  test 'should not save package without barcode' do
    package = Package.new

    assert_not package.save, 'Saved the package without a barcode'
  end

  test 'should not save package with duplicate barcode' do
    package = Package.last
    new_package = Package.new(barcode: package.barcode)
    new_package.valid?
    assert_equal ['has already been taken'], new_package.errors[:barcode]
  end

  test 'should not save package without delivery point' do
    package = Package.new(barcode: 'AC102')

    assert_not package.save, 'Saved the package without a delivery point'
  end

  test 'should not save package without volumetric weight' do
    package = Package.new(barcode: 'AC102', delivery_point_id: 1)

    assert_not package.save, 'Saved the package without a volumetric weight'
  end

  test 'could belong to a bag' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)

    assert package.save, 'Could not save the package'
    assert_not_nil package.bag, 'Package does not belong to a bag'
  end

  test 'should update state as created after create' do
    delivery_point = DeliveryPoint.last
    package = Package.new(barcode: 'AC102', delivery_point: delivery_point, volumetric_weight: 1)
    package.save

    assert_equal package.state, 1, 'Package state is not created'
  end

  test 'should update state as loaded after load' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
    package.save

    assert_equal package.state, 1, 'Package state is not created'
    package.load
    assert_equal package.state, 3, 'Package state is not loaded'
  end

  context 'when unloaded' do
    test 'should not unload package if delivery point is not valid' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      package.save
      package.load

      assert_equal package.state, 3, 'Package state is not loaded'
      assert_not package.unload('Invalid Type'), 'Unloaded the package'
      assert_equal package.state, 3, 'Package state is not loaded'
    end

    test 'should not unload package if package is not loaded yet' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      package.save

      assert_equal package.state, 1, 'Package state is not created'

      package.update!(state: 2)
      assert_not package.unload(delivery_point), 'Unloaded the package'
      assert_equal package.state, 2, 'Package state is not changed'
    end

    test 'should not unload package if package is not in the same delivery point' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      package.save
      package.load

      assert_equal package.state, 3, 'Package state is not loaded'
      assert_not package.unload(DeliveryPoint.first), 'Unloaded the package'
      assert_equal package.state, 3, 'Package state is not loaded'
    end

    test 'should unload package if package goes to Branch and not in a bag' do
      delivery_point = DeliveryPoint.find_by!(delivery_point: 'Branch')
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, volumetric_weight: 1)
      package.save
      package.load

      assert_equal package.state, 3, 'Package state is not loaded'
      package.unload(delivery_point)
      assert_equal package.state, 4, 'Package state is not unloaded'
    end

    test 'should unload package if package goes to Distribution Center' do
      delivery_point = DeliveryPoint.find_by!(delivery_point: 'Distribution Center')
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, volumetric_weight: 1)
      package.save
      package.load

      assert_equal package.state, 3, 'Package state is not loaded'
      package.unload(delivery_point)
      assert_equal package.state, 4, 'Package state is not unloaded'
    end

    test 'should unload package if package goes to Transfer Center and is in a bag' do
      delivery_point = DeliveryPoint.create(delivery_point: 'Transfer Center', value: 3)
      bag = Bag.create(barcode: 'AB102', delivery_point: delivery_point)
      package = Package.new(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      package.save
      package.load

      assert_equal package.state, 3, 'Package state is not loaded'
      package.unload(delivery_point)
      assert_equal package.state, 4, 'Package state is not unloaded'
    end
  end
end
