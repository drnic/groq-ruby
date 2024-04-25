#!/usr/bin/env ruby

require "optparse"
require "groq"
require "yaml"

include Groq::Helpers

@options = {
  model: "llama3-70b-8192",
  timeout: 20
}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb [options]"

  opts.on("-m", "--model MODEL", "Model name") do |v|
    @options[:model] = v
  end

  opts.on("-t", "--timeout TIMEOUT", "Timeout in seconds") do |v|
    @options[:timeout] = v.to_i
  end

  opts.on("-d", "--debug", "Enable debug mode") do |v|
    @options[:debug] = v
  end
end.parse!

raise "Missing --model option" if @options[:model].nil?

# Initialize the Groq client
@client = Groq::Client.new(model_id: @options[:model], request_timeout: @options[:timeout]) do |f|
  if @options[:debug]
    require "logger"

    # Create a logger instance
    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG

    f.response :logger, logger, bodies: true  # Log request and response bodies
  end
end

prompt = <<~TEXT
  Write out the names of the planets of our solar system, and a brief description of each one.

  Return JSON object for each one:

  { "name": "Mercury", "position": 1, "description": "Mercury is ..." }

  Between each response, say "NEXT" to clearly delineate each JSON response.
TEXT

# Handle each JSON object once it has been fully streamed

class PlanetStreamer
  def initialize
    @buffer = ""
  end

  def call(content)
    if !content || content.include?("NEXT")
      json = JSON.parse(@buffer)

      # do something with JSON, e.g. save to database
      pp json

      # reset buffer
      @buffer = ""
      return
    end
    # if @buffer is empty; and content is not JSON start {, then ignore + return
    if @buffer.empty? && !content.start_with?("{")
      return
    end

    # build JSON
    @buffer << content
  end
end

streamer = PlanetStreamer.new

@client.chat([S(prompt)], stream: streamer)
puts
