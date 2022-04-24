# frozen_string_literal: true

class CreateBags < ActiveRecord::Migration[6.1]
  def change
    create_table :bags do |t|
      t.string :barcode
      t.index :barcode, unique: true
      t.integer :state

      t.timestamps
    end
  end
end
