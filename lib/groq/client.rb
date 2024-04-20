require "faraday"

class Groq::Client
  def initialize(api_key: nil, api_url: nil)
    @api_key = ENV.fetch("GROQ_API_KEY", api_key)
    @api_url ||= "https://api.groq.com"
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
