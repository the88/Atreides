class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features, :force => true do |t|
      t.string :title
      t.integer :photo_id
      t.integer :post_id
      t.integer :display_order, :default => 0
      t.string :state
      t.string  :caption
      t.string  :url
      t.datetime :published_at
      t.timestamps
    end
    add_index :features, :photo_id
    add_index :features, :post_id
  end

  def self.down
    drop_table :features
  end
end
