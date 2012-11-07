class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences, :force => true do |t|
      t.string :key, :limit => 512
      t.text :value, :default => ''
      t.timestamps
    end
    add_index :preferences, :key
  end

  def self.down
    drop_table :preferences
  end
end
