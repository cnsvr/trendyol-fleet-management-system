# frozen_string_literal: true

class Package < ApplicationRecord
  include Shipment

  enum states: { 'CREATED' => 1, 'LOADED INTO BAG' => 2, 'LOADED' => 3, 'UNLOADED' => 4 }
  belongs_to :bag, required: false

  validates :state, inclusion: { in: states.values, if: :persisted? }
  validates :volumetric_weight, presence: true, numericality: { greater_than: 0 }
end
