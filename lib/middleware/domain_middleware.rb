class DomainMiddleware
  def initialize(app)
    @app = app
  end

  # route all:
  #   www.givebrand.com
  #   givebrand.com
  #   www.givebrand.to
  # to:
  #   givebrand.to
  def call(env)
    request = Rack::Request.new(env)
    if request.host.starts_with?("www.") || request.host.ends_with?(".com")
      [301, {"Location" => request.url.sub("//www.", "//").sub(".com", ".to")}, self]
    else
      @app.call(env)
    end
  end

  def each(&block)
  end
end
