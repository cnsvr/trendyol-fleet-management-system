class Vehicle < ApplicationRecord
     validates :plate, presence: true, uniqueness: true
end
