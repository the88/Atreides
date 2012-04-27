class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links, :force => true do |t|
      t.integer :post_id
      t.string :caption
      t.string :url
      t.integer :display_order, :default => 0
      t.timestamps
    end
    add_index :links, :post_id
  end

  def self.down
    drop_table :links
  end
end