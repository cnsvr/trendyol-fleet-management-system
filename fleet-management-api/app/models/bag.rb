# frozen_string_literal: true

class Bag < ApplicationRecord
  include Shipment

  enum states: { 'CREATED' => 1, 'LOADED' => 3, 'UNLOADED' => 4 }
  has_many :packages, dependent: :destroy

  validates :state, inclusion: { in: states.values, if: :persisted? }

  def volumetric_weight
    packages.sum(:volumetric_weight)
  end
end
