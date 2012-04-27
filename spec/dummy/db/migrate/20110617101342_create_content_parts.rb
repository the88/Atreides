class CreateContentParts < ActiveRecord::Migration
  def self.up
    create_table :content_parts, :force => true do |t|
      t.text        :body, :default => "" 
      t.references  :contentable, :polymorphic => true
      t.string      :display_type
      t.string      :content_type
      t.integer     :display_order, :default => 0
      t.timestamps
    end
    
    # Update videos table
    add_column :videos, :content_part_id, :integer
    # Migrate old videos to new content-parts
    # ...
    
    # Migrate posts bodies to content-parts
    Atreides::Post.where("post_type = 'post' AND body is not null").all.each do |p|
      p.parts.create(:content_type => 'text', :body => p.body)
    end

    # Migrate posts bodies to content-parts
    Atreides::Post.where("post_type = 'photos'").all.each do |p|
      photos = Atreides::Photo.where({:photoable_id => p.id, :photoable_type => 'Atreides::Post'}).all
      p.parts.create(:content_type => 'photos', :photos => photos) 
      p.parts.create(:content_type => 'text', :body => p.body) if p.body?
    end

    Atreides::Post.where("post_type = 'videos'").all.each do |p|
      videos = Atreides::Video.where({:post_id => p.id}).all
      p.parts.create(:content_type => 'videos', :videos => p.videos) 
      p.parts.create(:content_type => 'text', :body => p.body) if p.body?
    end

    remove_column :videos, :post_id
    remove_column :posts, :body
    remove_column :posts, :post_type

  end

  def self.down
    add_column :videos, :post_id, :integer
    # Migrate videos directly to posts
    # ...
    remove_column :videos, :content_part_id

    add_column :posts, :body, :text
    add_column :posts, :post_type, :string
    # Migrate content-parts to posts body and post_type
    Atreides::ContentPart.where("contentable_id is not null").each do |p|
      next if p.contentable.nil?
      post = p.contentable
      case p.content_type.to_sym
      when :text
        post.body = p.body
      when :photos
        post.photos = p.photos
      when :videos
        post.videos = p.videos
      end
      post.save
    end

    drop_table :content_parts
  end
end