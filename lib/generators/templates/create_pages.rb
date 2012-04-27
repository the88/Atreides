class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages, :force => true do |t|
      t.string :title
      t.text :body
      t.string :slug
      t.datetime :published_at
      t.string :state
      t.timestamps

      t.integer :likes_count, :default => 0
      t.integer :comments_count, :default => 0
      t.integer :votes_count, :default => 0

      t.integer :parent_id
      t.integer :position, :default => 0

      t.integer :post_id
    end
    add_index :pages, :slug
    add_index :pages, :likes_count
    add_index :pages, :comments_count
    add_index :pages, :votes_count
    add_index :pages, :parent_id
    add_index :pages, :post_id
  end

  def self.down
    drop_table :pages
  end
end
