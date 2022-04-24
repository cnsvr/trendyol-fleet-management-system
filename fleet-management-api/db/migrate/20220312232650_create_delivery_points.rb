# frozen_string_literal: true

class CreateDeliveryPoints < ActiveRecord::Migration[6.1]
  def change
    create_table :delivery_points do |t|
      t.string :delivery_point
      t.integer :value

      t.timestamps
    end
  end
end
