class PackageSerializer < ActiveModel::Serializer
  attributes :id, :barcode, :state, :delivery_point_id, :volumetric_weight, :created_at, :updated_at
  
  belongs_to :bag
  belongs_to :delivery_point
end
