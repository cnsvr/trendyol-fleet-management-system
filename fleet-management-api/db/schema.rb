# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_13_170520) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bags", force: :cascade do |t|
    t.string "barcode"
    t.integer "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "delivery_point_id", null: false
    t.index ["barcode"], name: "index_bags_on_barcode", unique: true
    t.index ["delivery_point_id"], name: "index_bags_on_delivery_point_id"
  end

  create_table "delivery_points", force: :cascade do |t|
    t.string "delivery_point"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "packages", force: :cascade do |t|
    t.string "barcode"
    t.integer "state"
    t.bigint "delivery_point_id"
    t.bigint "bag_id"
    t.integer "volumetric_weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bag_id"], name: "index_packages_on_bag_id"
    t.index ["barcode"], name: "index_packages_on_barcode", unique: true
    t.index ["delivery_point_id"], name: "index_packages_on_delivery_point_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "plate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bags", "delivery_points"
  add_foreign_key "packages", "bags"
  add_foreign_key "packages", "delivery_points"
end
