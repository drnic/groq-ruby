class Groq::Configuration
  attr_writer :api_key
  attr_accessor :model_id, :api_url, :request_timeout, :extra_headers

  DEFAULT_API_URL = "https://api.groq.com"
  DEFAULT_REQUEST_TIMEOUT = 5

  class Error < StandardError; end

  def initialize
    @api_key = ENV["GROQ_API_KEY"]
    @model_id = Groq::Model.default_model_id
    @api_url = DEFAULT_API_URL
    @request_timeout = DEFAULT_REQUEST_TIMEOUT
    @extra_headers = {}
  end

  def api_key
    return @api_key if @api_key
    raise Error, "No GROQ API key provided. Set via $GROQ_API_KEY or Groq.configuration.api_key"
  end
end
