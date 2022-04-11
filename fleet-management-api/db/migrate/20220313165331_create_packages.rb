class CreatePackages < ActiveRecord::Migration[6.1]
  def change
    create_table :packages do |t|
      t.string :barcode
      t.index :barcode, unique: true
      t.integer :state
      t.references :delivery_point, foreign_key: true
      t.references :bag, null: true, foreign_key: true
      t.integer :volumetric_weight

      t.timestamps
    end
  end
end
