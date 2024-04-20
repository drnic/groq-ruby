require "faraday"

class Groq::Client
  CONFIG_KEYS = %i[
    api_key
    api_url
    model_id
  ].freeze
  attr_reader(*CONFIG_KEYS, :faraday_middleware)

  class Error < StandardError; end

  def initialize(config = {}, &faraday_middleware)
    CONFIG_KEYS.each do |key|
      # Set instance variables like api_key.
      # Fall back to global config if not present.
      instance_variable_set(:"@#{key}", config[key] || Groq.configuration.send(key))
    end
    @faraday_middleware = faraday_middleware
  end

  def chat(messages, model_id: nil, tools: nil)
    unless messages.is_a?(Array) || messages.is_a?(String)
      raise ArgumentError, "require messages to be an Array or String"
    end

    if messages.is_a?(String)
      messages = [{role: "user", content: messages}]
    end

    model_id ||= @model_id

    body = {
      model: model_id,
      messages: messages,
      tools: tools
    }.compact
    response = post(path: "/openai/v1/chat/completions", body: body)
    if response.status == 200
      response.body.dig("choices", 0, "message")
    else
      raise Error, "Request failed with status #{response.status}: #{response.body}"
    end
  end

  def post(path:, body:)
    client.post do |req|
      req.url path
      req.headers["Authorization"] = "Bearer #{@api_key}"
      req.body = body
    end
  end

  def client
    @client ||= Faraday.new(url: @api_url) do |f|
      f.request :json # automatically encode the request body as JSON
      f.response :json # automatically decode JSON responses
      f.adapter Faraday.default_adapter
    end
  end
end
