class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table "orders", :force => true do |t|
      t.string   "state"
      t.integer  "user_id"
      t.integer  "amount_cents",                         :default => 0
      t.integer  "discount_cents",                       :default => 0
      t.integer  "final_amount_cents",                   :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "ip_address"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "zip",                  :limit => 15
      t.string   "country"
      t.string   "currency"
      t.string   "street"
      t.string   "city"
      t.string   "province"
      t.string   "payment_gateway"
      t.string   "gateway_data", :limit => 4000

      t.string   "email"
    end
    add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  end

  def self.down
    drop_table :orders
  end
end
