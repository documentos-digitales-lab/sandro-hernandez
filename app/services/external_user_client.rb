require "net/http"
require "json"
require "uri"
require "openssl"

class ExternalUserClient
  BASE_URL = "https://dummyjson.com/users"
  OPEN_TIMEOUT = 2
  READ_TIMEOUT = 3

  class Error < StandardError; end
  class HttpError < Error; end
  class TimeoutError < Error; end
  class ConnectionError < Error; end
  class ParseError < Error; end

  def self.call(id:)
    new(id: id).call
  end

  def initialize(id:, base_url: BASE_URL, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT)
    @uri = URI.parse("#{base_url}/#{id}")
    @open_timeout = open_timeout
    @read_timeout = read_timeout
  end

  def call
    response = http.get(@uri.request_uri)
    raise HttpError, "Unexpected status #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue Timeout::Error => e
    raise TimeoutError, e.message
  rescue SocketError, EOFError, SystemCallError, OpenSSL::SSL::SSLError => e
    raise ConnectionError, e.message
  rescue JSON::ParserError => e
    raise ParseError, e.message
  end

  private

  def http
    Net::HTTP.new(@uri.host, @uri.port).tap do |http|
      http.use_ssl = @uri.scheme == "https"
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout
    end
  end
end