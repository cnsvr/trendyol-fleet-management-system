# frozen_string_literal: true

require 'test_helper'

class BagTest < ActiveSupport::TestCase
  test 'should not save bag without barcode' do
    bag = Bag.new

    assert_not bag.save, 'Saved the bag without a barcode'
  end

  test 'should not save bag with duplicate barcode' do
    bag = Bag.last
    new_bag = Bag.new(barcode: bag.barcode)
    new_bag.valid?
    assert_equal ['has already been taken'], new_bag.errors[:barcode]
  end

  test 'should not save bag without delivery point' do
    bag = Bag.new(barcode: 'AB102')

    assert_not bag.save, 'Saved the bag without a delivery point'
  end

  test 'could have many packages' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    Package.create(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
    Package.create(barcode: 'AD102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)

    assert bag.save, 'Could not save the bag'
    assert_not_nil bag.packages, 'Bag does not have packages'
    assert_equal 2, bag.packages.count, 'Bag does not have 2 packages'
  end

  test 'should update state as created after create' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    bag.save

    assert_equal bag.state, 1, 'Bag state is not created'
  end

  test 'should return volumetric weight' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    Package.create(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 5)
    Package.create(barcode: 'AD102', delivery_point: delivery_point, bag: bag, volumetric_weight: 10)

    assert bag.save, 'Could not save the bag'
    assert_equal 15, bag.volumetric_weight, 'Bag does not have 2 packages'
  end

  # load and unload methods test

  test 'should update state as loaded after load' do
    delivery_point = DeliveryPoint.last
    bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
    bag.save

    assert_equal bag.state, 1, 'Bag state is not created'
    bag.load
    assert_equal bag.state, 3, 'Bag state is not loaded'
  end

  context 'when unloaded' do
    test 'should not unload bag if delivery point is not valid' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      assert_not bag.unload('Invalid Type'), 'Unloaded the bag'
      assert_equal bag.state, 3, 'Bag state is not loaded'
    end

    test 'should not unload bag if bag is not loaded yet' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      bag.save

      assert_equal bag.state, 1, 'Bag state is not created'

      assert_not bag.unload(delivery_point), 'Unloaded the bag'
      assert_equal bag.state, 1, 'Bag state is not changed'
    end

    test 'should not unload bag if bag is not in the same delivery point' do
      delivery_point = DeliveryPoint.last
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      assert_not bag.unload(DeliveryPoint.first), 'Unloaded the bag'
      assert_equal bag.state, 3, 'Bag state is not loaded'
    end

    test 'should unload bag if bag goes to Distribution Center' do
      delivery_point = DeliveryPoint.find_by!(delivery_point: 'Distribution Center')
      bag = Bag.new(barcode: 'AC102', delivery_point: delivery_point)
      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      bag.unload(delivery_point)
      assert_equal bag.state, 4, 'Bag state is not unloaded'
    end

    test 'should also unload packages in the bag if bag goes to Distribution Center' do
      delivery_point = DeliveryPoint.find_by!(delivery_point: 'Distribution Center')
      bag = Bag.new(barcode: 'AC102', delivery_point: delivery_point)
      Package.create(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      Package.create(barcode: 'AD102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)

      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      assert_equal bag.packages.first.state, 2, 'Package state in the bag is not loaded into bag'

      bag.unload(delivery_point)
      assert_equal bag.state, 4, 'Bag state is not unloaded'
      assert_equal bag.packages.first.state, 4, 'Package state in the bag is not unloaded'
      assert_equal bag.packages.second.state, 4, 'Bag state in the bag is not unloaded'
    end

    test 'should unload bag if bag goes to Transfer Center' do
      delivery_point = DeliveryPoint.create(delivery_point: 'Transfer Center', value: 3)
      bag = Bag.new(barcode: 'AB102', delivery_point: delivery_point)
      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      bag.unload(delivery_point)
      assert_equal bag.state, 4, 'Bag state is not unloaded'
    end

    test 'should also unload packages in the bag if bag goes to Transfer Center' do
      delivery_point = DeliveryPoint.create(delivery_point: 'Transfer Center', value: 3)
      bag = Bag.new(barcode: 'AC102', delivery_point: delivery_point)
      Package.create(barcode: 'AC102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)
      Package.create(barcode: 'AD102', delivery_point: delivery_point, bag: bag, volumetric_weight: 1)

      bag.save
      bag.load

      assert_equal bag.state, 3, 'Bag state is not loaded'
      assert_equal bag.packages.first.state, 2, 'Package state in the bag is not loaded into bag'

      bag.unload(delivery_point)
      assert_equal bag.state, 4, 'Bag state is not unloaded'
      assert_equal bag.packages.first.state, 4, 'Package state in the bag is not unloaded'
      assert_equal bag.packages.second.state, 4, 'Bag state in the bag is not unloaded'
    end
  end
end
