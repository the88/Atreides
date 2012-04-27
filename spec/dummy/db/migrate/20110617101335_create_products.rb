class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products, :force => true do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.integer :price_cents, :default => 0
      t.string :price_currency
      t.string :state
      t.datetime :published_at
      t.integer  :comments_count, :default => 0
      t.integer  :likes_count, :default => 0
      t.integer  :votes_count, :default => 0
      t.timestamps
    end
    add_index :products, :comments_count
    add_index :products, :likes_count
    add_index :products, :votes_count
  end

  def self.down
    drop_table :products
  end
end
