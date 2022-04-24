# frozen_string_literal: true

class Vehicle < ApplicationRecord
  validates :plate, presence: true, uniqueness: true
end
