class AddRoleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string
    Atreides::User.where(:admin => true).each do |user| 
      user.role = :admin 
      user.save
    end
    remove_column :users, :admin
  end

  def self.down
    add_column :users, :admin, :boolean, :default => false
    Atreides::User.where(:role => :admin).each {|user| user.update_attributes!(:admin => true)}
    remove_column :users, :role
  end
end
