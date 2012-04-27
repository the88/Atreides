class Atreides::Video < Atreides::Base

  #
  # Constants
  #
  attr_accessor :upload

  #
  # Associatons
  #
  belongs_to :part, :touch => true, :class_name => "Atreides::ContentPart"

  #
  # Validations
  #
  validates_presence_of :vimeo_id, :unless => :url?
  validates_presence_of :url, :unless => :vimeo_id?
  validates_format_of :url, :with => /^http:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :if => :url?

  before_validation :upload_video, :on => :create

  def upload_video

    # upload to vimeo
    send_to_vimeo if upload and File.exists?(upload)

    # Set embed code
    if !embedable? or url_changed?
      if embedable?(:url)
        self.embed = url
        doc = Hpricot(self.embed)

        # Get dimensions from embed code
        object = doc.at("object[@width][@height]")
        self.width = object.attributes['width'].to_i
        self.height = object.attributes['height'].to_i

        # Get url from embed code
        param = doc.at("param[@name=movie]")
        self.url = param.attributes['value']

        # Guess image url if from youtube
        if self.url =~ %r{^http://www.youtube.com/v/([0-9A-Za-z\-\_]+)\&.*$}
          self.thumb_url = "http://i1.ytimg.com/vi/#{$1}/default.jpg"
        end
      else
        require 'oembed_links'
        OEmbed.register_yaml_file(File.join(Rails.root, 'config/oembed.yml'))
        OEmbed.transform(url) do |r, url|
          r.from?(:youtube) { |resp|
            self.width     = resp["width"].to_i
            self.height    = resp["height"].to_i
            self.thumb_url = resp["thumbnail_url"]
            self.embed     = resp["html"]
            # Extract URL from embed html
            res = resp["html"].scan(/(http\:\/\/www\.youtube\.com\/embed\/.+?)\?/)
            self.url = res.flatten.shift
          }
          r.from?(:vimeo) { |resp|
            self.vimeo_id  = resp["video_id"]
            self.width     = resp["width"].to_i
            self.height    = resp["height"].to_i
            self.thumb_url = resp["thumbnail_url"]
            self.embed = resp["html"]
          }
          r.any? { |resp|
            self.embed = resp["html"]
            self.thumb_url = resp["thumbnail_url"]
          }
        end
      end
    end
  end

  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self

    def base_class
      self
    end

  end

  #
  # Instance Methods
  #
  def embedable?(target = :embed)
    send("#{target}?") and !send(target).strip.match(%r{^<\w+}).nil?
  end

  def embed(*args)
    html = read_attribute(:embed)
    dims = args.first if args.is_a?(Array)
    return html if !dims.is_a?(Hash) or html.blank?

    # Process embed for provided dimensions
    doc = Hpricot(html)
    %w(iframe object embed).each do |tag|
      el = doc.at("#{tag}[@width][@height]")
      next unless el
      unless dims[:width].blank?
        el.attributes['width']  = dims[:width].to_s
      end
      unless dims[:height].blank?
        el.attributes['height'] = dims[:height].to_s
      else
        unless dims[:width].blank?
          begin
            el.attributes['height'] = (( self.height * dims[:width]) / self.width).to_s
          rescue => e
            logger.error "VIDEO - Error while resizing embed video : " + e.backtrace.join("\n")
          end
        end
      end
    end
    doc.to_s
  end

  def embed_url(options = {})
    @embed_url ||= if embedable?
      # Parse for URL
      if (tag = Hpricot(embed).at('embed'))
        tag.attributes['src']
      elsif (tag = Hpricot(embed).at("param[@name='movie']"))
        tag.attributes['value']
      elsif (tag = Hpricot(embed).at("iframe[@src]"))
        tag.attributes['src']
      end
    elsif vimeo_id?
      params = {
        :clip_id => vimeo_id,
        :server => "vimeo.com",
        :show_title => 0,
        :show_byline => 0,
        :show_portrait => 0,
        :full_screen => 1,
        :color => "ffffff"
      }.update(options)
      "http://vimeo.com/moogaloop.swf?#{params.to_query}"
    else
      url
    end
  end

  def flash_vars
    @flash_vars ||= if vimeo_id?
      {:clip_id => vimeo_id, :server => 'vimeo.com', :fullscreen => 1, :show_title => 1, :show_byline => 1, :show_portrait => 1, :color => '00ADEF'}.to_json
    else
      {}.to_json
    end
  end

  def send_to_vimeo
    return unless upload.respond_to?(:path) and File.exists?(upload.path)

    # @vimeo.confirm("ticket_id", "json_manifest")
    quota = vimeo_upload.get_quota

    # Check size of upload
    if upload.size > quota['user']['upload_space']['free'].to_i
      return errors.add(:upload, "exceeds remaining Viemo quota")
    end

    ticket = vimeo_upload.get_ticket

    resp = vimeo_upload.upload(Settings.vimeo.user_token, upload.path, ticket['ticket']['id'], ticket['ticket']['endpoint'])
    conf = vimeo_upload.confirm(ticket['ticket']['id'])
    self.vimeo_id = conf['ticket']['video_id']

    # Set video's attributes
    if vimeo_id?
      begin
        vimeo_video.set_privacy(vimeo_id, "anybody")
        vimeo_video.set_description(vimeo_id, caption) if caption?
        if post
          # vimeo_video.set_title(vimeo_id, post.title) if post.title? # TODO: Why is the API broken here
          vimeo_video.add_tags(vimeo_id, post.tag_list.join(",")) unless post.tag_list.empty?
        end
      rescue Exception => exc
        logger.error { "Unable to set video attributes: #{exc}\nResp: #{resp.inspect}\nConf:#{conf}" }
      end
      self.upload = nil
    else
      logger.error { "Unable to save Vimeo video!\nResp: #{resp.inspect}\nConf:#{conf}" }
    end
    return vimeo_id?
  end

  private

  def vimeo_upload
    @vimeo_upload ||= Vimeo::Advanced::Upload.new(Settings.vimeo.consumer_key, Settings.vimeo.consumer_secret, :token => Settings.vimeo.user_token, :secret => Settings.vimeo.user_secret)
  end

  def vimeo_video
    @video_upload ||= Vimeo::Advanced::Atreides::Video.new(Settings.vimeo.consumer_key, Settings.vimeo.consumer_secret, :token => Settings.vimeo.user_token, :secret => Settings.vimeo.user_secret)
  end

  include Atreides::Extendable
end