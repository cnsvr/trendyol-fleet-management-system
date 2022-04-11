module Shipment
  extend ActiveSupport::Concern
  
  included do
    after_commit :update_state_to_created, on: :create

    belongs_to :delivery_point, required: true
    
    validates :barcode, presence: true, uniqueness: true
  end
  
  def load
    self.update(state: 3)
    self.load_all_packages if self.is_a?(Bag) && self.packages.present?
  end

  def unload(p)
    return unless p.is_a?(DeliveryPoint)
    return unless self.state == 3 # return if not loaded
    return unless self.delivery_point_id == p.id # return if not in the same delivery point

    case p.delivery_point
    when 'Branch'
      self.update(state: 4) if self.is_a?(Package) && !is_package_in_bag?
    when 'Distribution Center'
      self.update(state: 4) # unload bag or package
      self.unload_all_packages # unload all packages in bag
    when 'Transfer Center' 
      self.update(state: 4) if self.is_a?(Bag) || is_package_in_bag?
      self.unload_all_packages  # unload all packages in bag
    else raise 'Unknown delivery point'
    end
  end

  private

  def update_state_to_created
    self.update(state: 1)
  end

  def is_package_in_bag?
    self.bag.present?
  end

  def unload_all_packages
    return unless self.is_a?(Bag) && self.packages.present?
    self.packages.each do |p|
      p.update(state: 4)
    end
  end

  def load_all_packages
    self.packages.each do |p|
      p.update(state: 2)
    end
  end
  
end