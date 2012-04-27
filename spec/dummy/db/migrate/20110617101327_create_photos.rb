class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
      t.string :photoable_type
      t.integer :photoable_id
      t.string :caption
      t.string :url
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :sizes, :limit => 3000
      t.timestamps

      t.integer :display_order, :default => 0
    end
  end

  def self.down
    drop_table :photos
  end
end
