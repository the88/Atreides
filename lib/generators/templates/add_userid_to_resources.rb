class AddUseridToResources < ActiveRecord::Migration
  def self.up
    %w(posts pages).each do |table|
      add_column table.to_sym, :author_id, :integer
      add_column table.to_sym, :last_editor_id, :integer
    end
  end

  def self.down
    %w(posts pages).each do |table|
      remove_column table.to_sym, :author_id
      remove_column table.to_sym, :last_editor_id
    end
  end
end
