require "faraday"

class Groq::Client
  CONFIG_KEYS = %i[
    api_key
    api_url
    model_id
    max_tokens
    temperature
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

  # TODO: support stream: true; or &stream block
  def chat(messages, model_id: nil, tools: nil, max_tokens: nil, temperature: nil, json: false)
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
      tools: tools,
      max_tokens: max_tokens || @max_tokens,
      temperature: temperature || @temperature,
      response_format: json ? {type: "json_object"} : nil
    }.compact
    response = post(path: "/openai/v1/chat/completions", body: body)
    if response.status == 200
      response.body.dig("choices", 0, "message")
    else
      # TODO: send the response.body back in Error object
      puts "Error: #{response.status}"
      pp response.body
      raise Error, "Request failed with status #{response.status}: #{response.body}"
    end
  end

  def get(path:)
    client.get do |req|
      req.url path
      req.headers["Authorization"] = "Bearer #{@api_key}"
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
    @client ||= begin
      connection = Faraday.new(url: @api_url) do |f|
        f.request :json # automatically encode the request body as JSON
        f.response :json # automatically decode JSON responses
        f.adapter Faraday.default_adapter
      end
      @faraday_middleware&.call(connection)

      connection
    end
  end
end
