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

ActiveRecord::Schema.define(version: 20170512201152) do

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

  create_table "invoices", force: :cascade do |t|
    t.integer  "id_cloud",          null: false
    t.integer  "state"
    t.integer  "purchase_order_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["id_cloud"], name: "index_invoices_on_id_cloud", unique: true
    t.index ["purchase_order_id"], name: "index_invoices_on_purchase_order_id"
  end

  create_table "products", id: false, force: :cascade do |t|
    t.string   "sku",         null: false
    t.string   "description"
    t.string   "category"
    t.integer  "price"
    t.integer  "stock"
    t.boolean  "owner"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string   "id_cloud",           null: false
    t.integer  "state"
    t.string   "product_sku",        null: false
    t.string   "id_store_reception"
    t.string   "payment_method"
    t.boolean  "owner"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["id_cloud"], name: "index_purchase_orders_on_id_cloud", unique: true
  end

  create_table "recipes", force: :cascade do |t|
    t.string   "final_product_sku",  null: false
    t.string   "needed_product_sku", null: false
    t.string   "final_product_unit"
    t.integer  "requirement",        null: false
    t.string   "requirement_unit"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "suppliers", id: false, force: :cascade do |t|
    t.integer  "id",           null: false
    t.string   "id_cloud"
    t.string   "warehouse_id"
    t.string   "api_prod"
    t.string   "api_dev"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["id"], name: "index_products_on_id", unique: true
    t.index ["id_cloud"], name: "index_products_on_id_cloud", unique: true
  end

  create_table "warehouses", force: :cascade do |t|
    t.string   "id_cloud",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_cloud"], name: "index_warehouses_on_id_cloud", unique: true
  end

end
