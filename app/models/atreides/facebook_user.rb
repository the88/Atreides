class Atreides::FacebookUser

  class << self

    def clear
      ["user_id", "access_token", "expiration", "page_token"].each do |key|
        Atreides::Preference.set("facebook.#{key}",nil)
      end
    end

    def find_or_create(params)
      Rails.logger.debug("[FacebookUser] find_or_create")
      access_token = params[:access_token]
      user_id = params[:user_id]
      expiration = params[:expiry]

      # if !has_valid_token?
        # Current user is invalid or does not exist
        Rails.logger.debug("[FacebookUser] determined invalid token")
        # See if we can get an extended token
        token_hash = extend_token(access_token)
        if token_hash["status"] == "ok"
          Rails.logger.debug("[FacebookUser] got extended token")
          access_token = token_hash["access_token"]
          expiration = token_hash["expires"]
        else
          Rails.logger.debug("[FacebookUser] did not get extended token")
        end

        expiration_date = Time.now + expiration.to_i
        expiration_string = expiration_date.to_s(:db)

        fb_pref("user_id", user_id)
        fb_pref("access_token", access_token)
        fb_pref("expiration", expiration_string)
        Rails.logger.debug("[FacebookUser] set all vars")
      # else
      #   Rails.logger.debug("[FacebookUser] token is valid")
      # end

      Rails.logger.debug("[FacebookUser] leaving")
      true
    end

    # def has_valid_token?
    #   !(fb_pref("access_token").blank? || current_token_expired?)
    # end

    def current_token_expired?
      return true if fb_pref("expiration").blank?
      Time.parse(fb_pref("expiration")) < Time.now
    end

    # Returns @response
    # @response is a hash with either keys => ["access_token", "expires", "status"] or keys => ["status"]
    # You may check for errors with ["status"] == "error"
    def extend_token(token)
      begin
        response = MiniFB.fb_exchange_token(Settings.facebook.app_id, Settings.facebook.app_secret, token)
        response["status"] = "ok"
        response
      rescue => e
        {"status" => "error"}
      end
    end

    def authorize_page(page_id)
      Rails.logger.debug("[FacebookUser] authorize_page")
      response = fb.get(fb_pref("user_id"), :type => "accounts/#{page_id}")
      found = false
      response.data.each do |account|
        Rails.logger.debug("[FacebookUser] checking account #{account.id}")
        if account.id.to_s == page_id.to_s
          Rails.logger.debug("[FacebookUser] found account #{account.id}")
          fb_pref("page_token", account.access_token)
          found = true
          break
        end
      end

      found
    end

    private

    def fb
      MiniFB.disable_logging
      MiniFB::OAuthSession.new(fb_pref("access_token"))
    end

    def fb_pref(key,value = nil)
      if value.nil?
        Atreides::Preference.get("facebook.#{key}")
      else
        Atreides::Preference.set("facebook.#{key}",value)
      end
    end

  end



end