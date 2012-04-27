class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items, :force => true do |t|
      t.integer :product_id
      t.integer :order_id
      t.integer :user_id
      t.string :size
      t.integer :price_cents, :default => 0
      t.string :price_currency
      t.integer :qty, :default => 0
      t.timestamps
    end
    add_index :line_items, :order_id
    add_index :line_items, :product_id
    add_index :line_items, :user_id
  end

  def self.down
    drop_table :line_items
  end
end