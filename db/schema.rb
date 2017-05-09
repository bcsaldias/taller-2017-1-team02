# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170509221417) do

  create_table "contacts", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "supplier_id"
    t.integer  "priority"
    t.decimal  "expected_production_time"
    t.integer  "production_unit_cost"
    t.integer  "min_production_batch"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["product_id"], name: "index_contacts_on_product_id"
    t.index ["supplier_id"], name: "index_contacts_on_supplier_id"
  end

  create_table "products", id: false, force: :cascade do |t|
    t.integer  "sku",         null: false
    t.string   "description"
    t.string   "category"
    t.integer  "price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "recipes", force: :cascade do |t|
    t.integer  "final_product_id"
    t.integer  "needed_product_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["final_product_id"], name: "index_recipes_on_final_product_id"
    t.index ["needed_product_id"], name: "index_recipes_on_needed_product_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "key",          null: false
    t.string   "warehouse_id"
    t.string   "api_prod"
    t.string   "api_dev"
    t.integer  "group_number", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
