# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140308203447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "unaccent"
  enable_extension "pg_trgm"

  create_table "comments", force: true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_failures", force: true do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.string  "target_type"
    t.text    "exception_data"
    t.text    "stripe_charge_data"
    t.text    "description"
  end

  create_table "payments", force: true do |t|
    t.integer "target_id"
    t.string  "target_type"
    t.integer "user_id"
    t.integer "amount"
    t.text    "stripe_charge_data"
    t.text    "description"
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "target_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "slug"
    t.string   "email"
    t.string   "password_salt"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",            limit: 512
    t.float    "subscription_cost"
    t.string   "holder_name"
    t.string   "routing_number"
    t.string   "account_number"
    t.string   "stripe_user_id"
    t.string   "stripe_card_id"
    t.string   "last_four_cc_numbers"
    t.string   "card_type"
  end

end
