# frozen_string_literal: true

class DeliveryPoint < ApplicationRecord
  DELIVERY_POINTS = ['Branch', 'Distribution Center', 'Transfer Center'].freeze

  has_many :bags
  has_many :packages

  validates :delivery_point, presence: true, uniqueness: true,
                             inclusion: { in: DELIVERY_POINTS, message: "%{value} is not a valid delivery point. It has to be one of #{DELIVERY_POINTS.join(',')}" }
  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: true
end
