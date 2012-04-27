class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes, :force => true do |t|
      t.references  :likeable, :polymorphic => true
      t.integer     :user_id
      t.timestamps
    end
    add_index :likes, :likeable_type
    add_index :likes, :likeable_id
    add_index :likes, :user_id
  end

  def self.down
    drop_table :likes
  end
end