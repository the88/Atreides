class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.string :post_type
      t.string :title
      t.text :body
      t.string :slug
      t.datetime :published_at
      t.string :state
      t.timestamps
      t.integer :tumblr_id
      t.integer :likes_count, :default => 0
      t.integer :comments_count, :default => 0
      t.integer :votes_count, :default => 0
      t.integer :twitter_id
      t.integer :facebook_id
      t.string :display_type
      t.integer :tw_delayed_job_id
      t.integer :fb_delayed_job_id
      t.integer :tumblr_delayed_job_id
      t.string :social_msg, :limit => 140
      t.integer :linkable_id
      t.string :linkable_type
      t.string :import_url
    end
    add_index :posts, :slug
    add_index :posts, :likes_count
    add_index :posts, :comments_count
    add_index :posts, :votes_count
    add_index :posts, :twitter_id
    add_index :posts, :linkable_id
    add_index :posts, :tumblr_delayed_job_id
  end

  def self.down
    drop_table :posts
  end
end
