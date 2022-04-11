class BagSerializer < ActiveModel::Serializer
  attributes :id, :barcode, :state, :delivery_point_id, :volumetric_weight, :created_at, :updated_at
  
  belongs_to :delivery_point
  has_many :packages
end
