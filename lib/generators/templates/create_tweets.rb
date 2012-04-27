class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets, :force => true do |t|
      t.datetime :tweeted_at
      t.string :text, :length => 140
      if Rails.database.mysql? 
        t.column :twitter_id, 'BIGINT UNSIGNED'
      elsif Rails.database.postgresql?
        t.column :twitter_id, 'BIGINT'
      end
      t.integer :twitter_id, :limit => 20
      t.string :from_user
      t.string :profile_image_url
      t.string :to_user
      t.integer :reach, :default => 0
      t.timestamps
    end
    add_index :tweets, :tweeted_at
    add_index :tweets, :twitter_id, :unique => true
  end

  def self.down
    drop_table :tweets
  end
end