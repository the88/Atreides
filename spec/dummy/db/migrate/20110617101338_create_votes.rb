class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :force => true do |t|
      t.string :votable_type
      t.integer :votable_id
      t.integer :value
      t.integer :user_id
      t.string :ip
      t.timestamps
    end
    add_index :votes, :votable_type
    add_index :votes, :votable_id
    add_index :votes, :user_id
    add_index :votes, :ip
  end

  def self.down
    drop_table :votes
  end
end