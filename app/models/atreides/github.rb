class Atreides::Github
  attr_reader :data

  def initialize(json_data)
    @data = Hashie::Mash.new(json_data)
  end

  def method_missing(method)
    @data.send(method)
  end

  def comments
    id = @data.number
    @comments ||= get_comments(id)
  end


  class << self
    def all(options={})
      issues(options)
    end

    def find(id)
      Atreides::Github.new(issue(id))
    end

    def issue(id)
      JSON.parse( get("repos/#{Settings.github.user}/#{Settings.github.repo}/issues/#{id}").body )
    end

    def issues(options)
      options.reverse_merge!({:labels => "site,review me"})
      JSON.parse( get("repos/#{Settings.github.user}/#{Settings.github.repo}/issues", {:params => options}).body )
    end

    def get(method, params={})
      access_token.get("https://api.github.com/#{method}", params)
    end

    def authorize_url
      client.auth_code.authorize_url(:redirect_uri => Settings.github.callback, :scope => Settings.github.scope)
    end

    def get_token(code)
      client.auth_code.get_token(code, :redirect_uri => Settings.github.callback)
    end

  private

    def client
      OAuth2::Client.new( Settings.github.id,
                          Settings.github.secret,
                            :site => "https://github.com/",
                            :authorize_url => Settings.github.auth_url,
                            :token_url => Settings.github.access_token_url,
                            :http_method => :get
                          )
    end

    def access_token
     OAuth2::AccessToken.new( client, Settings.github.token )
    end



  end

  private

  def get_comments(id)
    JSON.parse( Atreides::Github.get("repos/#{Settings.github.user}/#{Settings.github.repo}/issues/#{id}/comments").body )
  end

end