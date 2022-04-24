# frozen_string_literal: true

require 'test_helper'

class VehicleTest < ActiveSupport::TestCase
  test 'should not save vehicle without plate number' do
    v = Vehicle.new
    assert_not v.save, 'Saved without a plate number'
  end

  test 'should not save vehicle without a unique plate number' do
    v = Vehicle.new(plate: 'ABC123')
    assert v.save, 'Saved with a unique plate number'
    v = Vehicle.new(plate: 'ABC123')
    assert_not v.save, 'Saved with a duplicate plate number'
  end
end
