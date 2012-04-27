# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110617101343) do

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment",                        :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "moderated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "content_parts", :force => true do |t|
    t.text     "body",             :default => ""
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.string   "display_type"
    t.string   "content_type"
    t.integer  "display_order",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "features", :force => true do |t|
    t.string   "title"
    t.integer  "photo_id"
    t.integer  "post_id"
    t.integer  "display_order", :default => 0
    t.string   "state"
    t.string   "caption"
    t.string   "url"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

  add_index "features", ["photo_id"], :name => "index_features_on_photo_id"
  add_index "features", ["post_id"], :name => "index_features_on_post_id"
  add_index "features", ["site_id"], :name => "index_features_on_site_id"

  create_table "likes", :force => true do |t|
    t.integer  "likeable_id"
    t.string   "likeable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "likes", ["likeable_id"], :name => "index_likes_on_likeable_id"
  add_index "likes", ["likeable_type"], :name => "index_likes_on_likeable_type"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "line_items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "order_id"
    t.integer  "user_id"
    t.string   "size"
    t.integer  "price_cents",    :default => 0
    t.string   "price_currency"
    t.integer  "qty",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "line_items", ["product_id"], :name => "index_line_items_on_product_id"
  add_index "line_items", ["user_id"], :name => "index_line_items_on_user_id"

  create_table "links", :force => true do |t|
    t.integer  "post_id"
    t.string   "caption"
    t.string   "url"
    t.integer  "display_order", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["post_id"], :name => "index_links_on_post_id"

  create_table "messages", :force => true do |t|
    t.string   "name"
    t.string   "subject"
    t.string   "email"
    t.text     "body"
    t.string   "messagable_type"
    t.integer  "messagable_id"
    t.integer  "user_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["messagable_id"], :name => "index_messages_on_messagable_id"
  add_index "messages", ["messagable_type"], :name => "index_messages_on_messagable_type"

  create_table "orders", :force => true do |t|
    t.string   "state"
    t.integer  "user_id"
    t.integer  "amount_cents",                       :default => 0
    t.integer  "discount_cents",                     :default => 0
    t.integer  "final_amount_cents",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "zip",                :limit => 15
    t.string   "country"
    t.string   "currency"
    t.string   "street"
    t.string   "city"
    t.string   "province"
    t.string   "payment_gateway"
    t.string   "gateway_data",       :limit => 4000
    t.string   "email"
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "slug"
    t.datetime "published_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes_count",    :default => 0
    t.integer  "comments_count", :default => 0
    t.integer  "votes_count",    :default => 0
    t.integer  "parent_id"
    t.integer  "position",       :default => 0
    t.integer  "post_id"
    t.integer  "site_id"
    t.integer  "author_id"
    t.integer  "last_editor_id"
  end

  add_index "pages", ["comments_count"], :name => "index_pages_on_comments_count"
  add_index "pages", ["likes_count"], :name => "index_pages_on_likes_count"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["post_id"], :name => "index_pages_on_post_id"
  add_index "pages", ["site_id"], :name => "index_pages_on_site_id"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"
  add_index "pages", ["votes_count"], :name => "index_pages_on_votes_count"

  create_table "photos", :force => true do |t|
    t.string   "photoable_type"
    t.integer  "photoable_id"
    t.string   "caption"
    t.string   "url"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "sizes",              :limit => 3000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",                      :default => 0
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.datetime "published_at"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tumblr_id"
    t.integer  "likes_count",                          :default => 0
    t.integer  "comments_count",                       :default => 0
    t.integer  "votes_count",                          :default => 0
    t.integer  "twitter_id"
    t.integer  "facebook_id"
    t.string   "display_type"
    t.integer  "tw_delayed_job_id"
    t.integer  "fb_delayed_job_id"
    t.integer  "tumblr_delayed_job_id"
    t.string   "social_msg",            :limit => 140
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.string   "import_url"
    t.integer  "site_id"
    t.integer  "author_id"
    t.integer  "last_editor_id"
  end

  add_index "posts", ["comments_count"], :name => "index_posts_on_comments_count"
  add_index "posts", ["likes_count"], :name => "index_posts_on_likes_count"
  add_index "posts", ["linkable_id"], :name => "index_posts_on_linkable_id"
  add_index "posts", ["site_id"], :name => "index_posts_on_site_id"
  add_index "posts", ["slug"], :name => "index_posts_on_slug"
  add_index "posts", ["tumblr_delayed_job_id"], :name => "index_posts_on_tumblr_delayed_job_id"
  add_index "posts", ["twitter_id"], :name => "index_posts_on_twitter_id"
  add_index "posts", ["votes_count"], :name => "index_posts_on_votes_count"

  create_table "products", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.integer  "price_cents",    :default => 0
    t.string   "price_currency"
    t.string   "state"
    t.datetime "published_at"
    t.integer  "comments_count", :default => 0
    t.integer  "likes_count",    :default => 0
    t.integer  "votes_count",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["comments_count"], :name => "index_products_on_comments_count"
  add_index "products", ["likes_count"], :name => "index_products_on_likes_count"
  add_index "products", ["votes_count"], :name => "index_products_on_votes_count"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "lang"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["name"], :name => "index_sites_on_name", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tweets", :force => true do |t|
    t.datetime "tweeted_at"
    t.string   "text"
    t.integer  "twitter_id",        :limit => 20
    t.string   "from_user"
    t.string   "profile_image_url"
    t.string   "to_user"
    t.integer  "reach",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweets", ["tweeted_at"], :name => "index_tweets_on_tweeted_at"
  add_index "tweets", ["twitter_id"], :name => "index_tweets_on_twitter_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "videos", :force => true do |t|
    t.string   "caption"
    t.string   "url",             :limit => 3000
    t.string   "vimeo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",                   :default => 0
    t.string   "embed",           :limit => 3000
    t.integer  "width"
    t.integer  "height"
    t.string   "thumb_url"
    t.integer  "content_part_id"
  end

  create_table "votes", :force => true do |t|
    t.string   "votable_type"
    t.integer  "votable_id"
    t.integer  "value"
    t.integer  "user_id"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["ip"], :name => "index_votes_on_ip"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["votable_id"], :name => "index_votes_on_votable_id"
  add_index "votes", ["votable_type"], :name => "index_votes_on_votable_type"

end
