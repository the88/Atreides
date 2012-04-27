class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :force => true do |t|
      t.string :name
      t.string :subject
      t.string :email
      t.text :body
      t.string :messagable_type
      t.integer :messagable_id
      t.integer :user_id
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.timestamps
    end
    add_index :messages, :messagable_type
    add_index :messages, :messagable_id
  end

  def self.down
    drop_table :messages
  end
end