# frozen_string_literal: true

module Shipment
  extend ActiveSupport::Concern

  included do
    after_commit :update_state_to_created, on: :create

    belongs_to :delivery_point, required: true

    validates :barcode, presence: true, uniqueness: true
  end

  def load
    update(state: 3)
    load_all_packages if is_a?(Bag) && packages.present?
  end

  def unload(p)
    return unless p.is_a?(DeliveryPoint)
    return unless state == 3 # return if not loaded
    return unless delivery_point_id == p.id # return if not in the same delivery point

    case p.delivery_point
    when 'Branch'
      update(state: 4) if is_a?(Package) && !package_in_bag?
    when 'Distribution Center'
      update(state: 4) # unload bag or package
      unload_all_packages # unload all packages in bag
    when 'Transfer Center'
      update(state: 4) if is_a?(Bag) || package_in_bag?
      unload_all_packages  # unload all packages in bag
    end
  end

  private

  def update_state_to_created
    update(state: 1)
  end

  def package_in_bag?
    bag.present?
  end

  def unload_all_packages
    return unless is_a?(Bag) && packages.present?

    packages.each do |p|
      p.update(state: 4)
    end
  end

  def load_all_packages
    packages.each do |p|
      p.update(state: 2)
    end
  end
end
