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

ActiveRecord::Schema[7.0].define(version: 2026_09_23_213820) do
  create_table "customers", charset: "utf8mb3", force: :cascade do |t|
    t.string "rfc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rfc"], name: "index_customers_on_rfc", unique: true
  end

  create_table "invoices", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "uuid"
    t.decimal "subtotal", precision: 10, scale: 2
    t.decimal "tax", precision: 10, scale: 2
    t.decimal "total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["uuid"], name: "index_invoices_on_uuid", unique: true
  end

  create_table "items", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.string "description", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_items_on_invoice_id"
  end

  add_foreign_key "invoices", "customers"
  add_foreign_key "items", "invoices"
end
