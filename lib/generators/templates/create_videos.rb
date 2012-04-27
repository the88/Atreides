class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos, :force => true do |t|
      t.integer :post_id
      t.string :caption
      t.string :url, :limit => 3000
      t.string :vimeo_id
      t.timestamps

      t.integer :display_order, :default => 0

      t.string :embed, :limit => 3000

      t.integer :width
      t.integer :height
      t.string :thumb_url
    end
    add_index :videos, :post_id
  end

  def self.down
    drop_table :videos
  end
end
