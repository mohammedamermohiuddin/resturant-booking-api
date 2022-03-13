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

ActiveRecord::Schema.define(version: 2022_03_12_142443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "reservations", force: :cascade do |t|
    t.integer "no_of_customers", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.bigint "table_id", null: false
    t.bigint "added_by_id"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.bigint "deleted_by_id"
    t.string "main_customer_name", null: false
    t.string "main_customer_phone", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["added_by_id"], name: "index_reservations_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_reservations_on_deleted_by_id"
    t.index ["table_id"], name: "index_reservations_on_table_id"
  end

  create_table "tables", force: :cascade do |t|
    t.integer "table_number", null: false
    t.integer "number_of_seats", null: false
    t.bigint "added_by_id"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "deleted_by_id"
    t.index ["added_by_id"], name: "index_tables_on_added_by_id"
    t.index ["deleted_by_id"], name: "index_tables_on_deleted_by_id"
  end

# Could not dump table "users" because of following StandardError
#   Unknown type 'user_role' for column 'role'

  add_foreign_key "reservations", "tables"
  add_foreign_key "reservations", "users", column: "added_by_id"
  add_foreign_key "reservations", "users", column: "deleted_by_id"
  add_foreign_key "tables", "users", column: "added_by_id"
  add_foreign_key "tables", "users", column: "deleted_by_id"
end
