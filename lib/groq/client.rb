require "faraday"

class Groq::Client
  CONFIG_KEYS = %i[
    api_key
    api_url
    model_id
    max_tokens
    temperature
    request_timeout
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

  def chat(messages, model_id: nil, tools: nil, tool_choice: nil, max_tokens: nil, temperature: nil, json: false, stream: nil, &stream_chunk)
    unless messages.is_a?(Array) || messages.is_a?(String)
      raise ArgumentError, "require messages to be an Array or String"
    end

    if messages.is_a?(String)
      messages = [{role: "user", content: messages}]
    end

    model_id ||= @model_id

    if stream_chunk ||= stream
      require "event_stream_parser"
    end

    body = {
      model: model_id,
      messages: messages,
      tools: tools,
      tool_choice: tool_choice,
      max_tokens: max_tokens || @max_tokens,
      temperature: temperature || @temperature,
      response_format: json ? {type: "json_object"} : nil,
      stream_chunk: stream_chunk
    }.compact
    response = post(path: "/openai/v1/chat/completions", body: body)
    # Configured to raise exceptions on 4xx/5xx responses
    if response.body.is_a?(Hash)
      return response.body.dig("choices", 0, "message")
    end
    response.body
  end

  def get(path:)
    client.get(path) do |req|
      req.headers = headers
    end
  end

  def post(path:, body:)
    client.post(path) do |req|
      configure_json_post_request(req, body)
    end
  end

  def client
    @client ||= begin
      connection = Faraday.new(url: @api_url) do |f|
        f.request :json # automatically encode the request body as JSON
        f.response :json # automatically decode JSON responses
        f.response :raise_error # raise exceptions on 4xx/5xx responses

        f.adapter Faraday.default_adapter
        f.options[:timeout] = request_timeout
      end
      @faraday_middleware&.call(connection)

      connection
    end
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "User-Agent" => "groq-ruby/#{Groq::VERSION}"
    }
  end

  #
  # Code/ideas borrowed from lib/openai/http.rb in https://github.com/alexrudall/ruby-openai/
  #

  def configure_json_post_request(req, body)
    req_body = body.dup

    if body[:stream_chunk].respond_to?(:call)
      req.options.on_data = to_json_stream(user_proc: body[:stream_chunk])
      req_body[:stream] = true # Tell Groq to stream
      req_body.delete(:stream_chunk)
    elsif body[:stream_chunk]
      raise ArgumentError, "The stream_chunk parameter must be a Proc or have a #call method"
    end

    req.headers = headers
    req.body = req_body
  end

  # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
  # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could
  # be a data object or an error object as described in the OpenAI API documentation.
  #
  # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
  # @return [Proc] An outer proc that iterates over a raw stream, converting it to JSON.
  def to_json_stream(user_proc:)
    parser = EventStreamParser::Parser.new

    proc do |chunk, _bytes, env|
      if env && env.status != 200
        raise_error = Faraday::Response::RaiseError.new
        raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
      end

      parser.feed(chunk) do |_type, data|
        next if data == "[DONE]"
        chunk = JSON.parse(data)
        delta = chunk.dig("choices", 0, "delta")
        content = delta.dig("content")
        if user_proc.is_a?(Proc)
          # if user_proc takes one argument, pass the content
          if user_proc.arity == 1
            user_proc.call(content)
          else
            user_proc.call(content, chunk)
          end
        elsif user_proc.respond_to?(:call)
          # if call method takes one argument, pass the content
          if user_proc.method(:call).arity == 1
            user_proc.call(content)
          else
            user_proc.call(content, chunk)
          end
        else
          raise ArgumentError, "The stream_chunk parameter must be a Proc or have a #call method"
        end
      end
    end
  end

  def try_parse_json(maybe_json)
    JSON.parse(maybe_json)
  rescue JSON::ParserError
    maybe_json
  end
end
