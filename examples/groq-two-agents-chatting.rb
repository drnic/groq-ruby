#!/usr/bin/env ruby
#
# This is a variation of groq-user-chat.rb but without any user prompting.
# Just two agents chatting with each other.

require "optparse"
require "groq"
require "yaml"

include Groq::Helpers

@options = {
  model: "llama3-8b-8192",
  # model: "llama3-70b-8192",
  agent_prompt_paths: [],
  timeout: 20,
  interaction_count: 10 # total count of interactions between agents
}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby script.rb [options]"

  opts.on("-m", "--model MODEL", "Model name") do |v|
    @options[:model] = v
  end

  opts.on("-a", "--agent-prompt PATH", "Path to an agent prompt file") do |v|
    @options[:agent_prompt_paths] << v
  end

  opts.on("-t", "--timeout TIMEOUT", "Timeout in seconds") do |v|
    @options[:timeout] = v.to_i
  end

  opts.on("-d", "--debug", "Enable debug mode") do |v|
    @options[:debug] = v
  end

  opts.on("-i", "--interaction-count COUNT", "Total count of interactions between agents") do |v|
    @options[:interaction_count] = v.to_i
  end
end.parse!

raise "New two --agent-prompt paths" if @options[:agent_prompt_paths]&.length&.to_i != 2

def debug?
  @options[:debug]
end

# Will be instantiated from the agent prompt file
class Agent
  def initialize(args = {})
    args.each do |k, v|
      instance_variable_set(:"@#{k}", v)
    end
    @messages = [S(@system_prompt)]
  end
  attr_reader :messages
  attr_reader :name, :can_go_first, :user_emoji, :agent_emoji, :system_prompt
  def can_go_first?
    @can_go_first
  end

  def self.load_from_file(path)
    new(YAML.load_file(path))
  end
end

# Read the agent prompt from the file
agents = @options[:agent_prompt_paths].map do |agent_prompt_path|
  Agent.load_from_file(agent_prompt_path)
end
go_first = agents.find { |agent| agent.can_go_first? } || agents.first

# check that each agent contains a system prompt
agents.each do |agent|
  raise "Agent #{agent.name} is missing a system prompt" if agent.system_prompt.nil?
end

# Initialize the Groq client
@client = Groq::Client.new(model_id: @options[:model], request_timeout: @options[:timeout]) do |f|
  if debug?
    require "logger"

    # Create a logger instance
    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG

    f.response :logger, logger, bodies: true  # Log request and response bodies
  end
end

puts "Welcome to a conversation between #{agents.map(&:name).join(", ")}. Our first speaker will be #{go_first.name}."
puts "You can quit by typing 'exit'."

agent_speaking_index = agents.index(go_first)
loop_count = 0

loop do
  speaking_agent = agents[agent_speaking_index]
  # Show speaking agent emoji immediately to indicate request going to Groq API
  print("#{speaking_agent.agent_emoji} ")

  # Use Groq to generate a response
  response = @client.chat(speaking_agent.messages)

  # Finish the speaking agent line on screen with message response
  puts(message = response.dig("content"))

  # speaking agent tracks its own message as the Assistant
  speaking_agent.messages << A(message)

  # other agent tracks the message as the User
  other_agents = agents.reject { |agent| agent == speaking_agent }
  other_agents.each do |agent|
    agent.messages << U(message)
  end

  agent_speaking_index = (agent_speaking_index + 1) % agents.length
  loop_count += 1
  break if loop_count > @options[:interaction_count]
rescue Faraday::TooManyRequestsError
  warn "...\n\nGroq API error: too many requests. Exiting."
  exit 1
end
