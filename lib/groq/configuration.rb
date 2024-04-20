class Groq::Configuration
  attr_writer :api_key
  attr_accessor :model_id, :max_tokens, :temperature
  attr_accessor :api_url, :request_timeout, :extra_headers

  DEFAULT_API_URL = "https://api.groq.com"
  DEFAULT_REQUEST_TIMEOUT = 5
  DEFAULT_MAX_TOKENS = 1024
  DEFAULT_TEMPERATURE = 1

  class Error < StandardError; end

  def initialize
    @api_key = ENV["GROQ_API_KEY"]
    @api_url = DEFAULT_API_URL
    @request_timeout = DEFAULT_REQUEST_TIMEOUT
    @extra_headers = {}

    @model_id = Groq::Model.default_model_id
    @max_tokens = DEFAULT_MAX_TOKENS
    @temperature = DEFAULT_TEMPERATURE
  end

  def api_key
    return @api_key if @api_key
    raise Error, "No GROQ API key provided. Set via $GROQ_API_KEY or Groq.configuration.api_key"
  end
end
