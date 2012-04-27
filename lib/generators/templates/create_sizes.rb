class CreateSizes < ActiveRecord::Migration
  def self.up
    create_table :sizes, :force => true do |t|
      t.integer :product_id
      t.string :name
      t.integer :qty
      t.integer :display_order, :default => 0
      t.timestamps
    end
    add_index :sizes, :product_id
  end

  def self.down
    drop_table :sizes
  end
end
