Net::HTTP.class_eval do
  def request(req, body = nil, &block)
    return orig_net_http_request(req, body, &block) unless ::EM.reactor_running?

    uri = Addressable::URI.parse("#{use_ssl? ? 'https://' : 'http://'}#{addr_port}#{req.path}")

    body = body || req.body
    opts = body.nil? ? {} : {:body => body}
    if use_ssl?
      sslopts = opts[:ssl] = {}
      sslopts[:verify_peer] = verify_mode == OpenSSL::SSL::VERIFY_PEER
      sslopts[:private_key_file] = key if key
      sslopts[:cert_chain_file] = ca_file if ca_file
    end
    opts[:timeout] = self.read_timeout

    # em-http-request not not decode GZip
    opts[:decoding] = false

    headers = opts[:head] = {}
    req.each do |k, v|
      headers[k] = v
    end

    headers['content-type'] ||= "application/x-www-form-urlencoded"
    
    t0 = Time.now
    httpreq = EM::HttpRequest.new(uri).send(req.class::METHOD.downcase.to_sym, opts)

    f=Fiber.current

    convert_em_http_response = lambda do |res|
      emres = EM::NetHTTP::Response.new(res.response_header)
      emres.set_body res.response
      nhresclass = Net::HTTPResponse.response_class(emres.code)
      nhres = nhresclass.new(emres.http_version, emres.code, emres.message)
      emres.to_hash.each do |k, v|
        nhres.add_field(k, v)
      end
      nhres.body = emres.body if req.response_body_permitted? && nhresclass.body_permitted?
      nhres.instance_variable_set '@read', true
      f.resume nhres
    end

    if block_given?
      httpreq.headers { |headers|
        emres = EM::NetHTTP::Response.new(headers)
        nhresclass = Net::HTTPResponse.response_class(emres.code)
        nhres = nhresclass.new(emres.http_version, emres.code, emres.message)
        emres.to_hash.each do |k, v|
          nhres.add_field(k, v)
        end
        f.resume nhres
      }

      nhres = Fiber.yield
      nhres.instance_variable_set :@httpreq, httpreq

      yield nhres
      nhres
    else
      httpreq.callback &convert_em_http_response
      httpreq.errback {|err|f.resume(:error)}
      res = Fiber.yield

      if res == :error
        raise 'EM::HttpRequest error - request timed out' if Time.now - self.read_timeout > t0
        raise 'EM::HttpRequest error - unknown error'
      end

      res
    end
  end
end if defined? EventMachine::NetHTTP # We only need to load this file when using em-net-http