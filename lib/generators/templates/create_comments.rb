class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.string      :title, :limit => 50, :default => "" 
      t.text        :comment, :default => "" 
      t.references  :commentable, :polymorphic => true
      t.integer     :user_id
      t.datetime    :moderated_at
      t.timestamps
    end
    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end