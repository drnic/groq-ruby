#!/usr/bin/env ruby

require "optparse"
require "groq"
require "yaml"

include Groq::Helpers

@options = {
  model: "llama3-70b-8192",
  agent_prompt_path: File.join(File.dirname(__FILE__), "agent-prompts/helloworld.yml"),
  timeout: 20
}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb [options]"

  opts.on("-m", "--model MODEL", "Model name") do |v|
    @options[:model] = v
  end

  opts.on("-a", "--agent-prompt PATH", "Path to agent prompt file") do |v|
    @options[:agent_prompt_path] = v
  end

  opts.on("-t", "--timeout TIMEOUT", "Timeout in seconds") do |v|
    @options[:timeout] = v.to_i
  end

  opts.on("-d", "--debug", "Enable debug mode") do |v|
    @options[:debug] = v
  end
end.parse!

raise "Missing --model option" if @options[:model].nil?
raise "Missing --agent-prompt option" if @options[:agent_prompt_path].nil?

# Read the agent prompt from the file
agent_prompt = YAML.load_file(@options[:agent_prompt_path])
user_emoji = agent_prompt["user_emoji"]
agent_emoji = agent_prompt["agent_emoji"]
system_prompt = agent_prompt["system_prompt"] || agent_prompt["system"]
can_go_first = agent_prompt["can_go_first"]

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

puts "Welcome to the AI assistant! I'll respond to your queries."
puts "You can quit by typing 'exit'."

def produce_summary(messages)
  combined = messages.map do |message|
    if message["role"] == "user"
      "User: #{message["content"]}"
    else
      "Assistant: #{message["content"]}"
    end
  end.join("\n")
  response = @client.chat([
    S("You are excellent at reading a discourse between a human and an AI assistant and summarising the current conversation."),
    U("Here is the current conversation:\n\n------\n\n#{combined}")
  ])
  puts response["content"]
end

messages = [S(system_prompt)]

if can_go_first
  print "#{agent_emoji} "
  message_bits = []
  response = @client.chat(messages) do |content|
    # content == nil on last message; and "" on first message
    next unless content
    print(content)
    message_bits << content
  end
  puts
  messages << A(message_bits.join(""))
end

class MessageBits
  def initialize(emoji)
    print "#{emoji} "
    @bits = []
  end

  def call(content)
    if content.nil?
      puts
    else
      print(content)
      @bits << content
    end
  end

  def to_assistant_message
    Assistant(@bits.join(""))
  end
end

loop do
  print "#{user_emoji} "
  user_input = gets.chomp

  break if user_input.downcase == "exit"

  # produce summary
  if user_input.downcase == "summary"
    produce_summary(messages)
    next
  end

  messages << U(user_input)

  # Use Groq to generate a response
  message_bits = MessageBits.new(agent_emoji)
  @client.chat(messages, stream: message_bits)
  messages << message_bits.to_assistant_message
end
