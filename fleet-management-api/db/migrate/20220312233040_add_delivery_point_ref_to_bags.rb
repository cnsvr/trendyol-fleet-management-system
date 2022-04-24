# frozen_string_literal: true

class AddDeliveryPointRefToBags < ActiveRecord::Migration[6.1]
  def change
    add_reference :bags, :delivery_point, null: false, foreign_key: true
  end
end
