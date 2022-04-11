class DeliveryPointSerializer < ActiveModel::Serializer
     attributes :id, :delivery_point, :value
     
     has_many :bags
     has_many :packages
   end
   