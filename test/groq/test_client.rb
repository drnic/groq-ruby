# frozen_string_literal: true

require "test_helper"

class TestGroqClient < Minitest::Test
  def test_defaults
    client = Groq::Client.new
    assert_equal "llama3-8b-8192", client.model_id
    assert_equal 1024, client.max_tokens
    assert_equal 1, client.temperature
  end

  # define "say hello world" for each model, such as: test_hello_world_llama3_8b et al
  Groq::Model::MODELS.each do |model|
    model_id = model[:model_id]
    define_method :"test_hello_world_#{model_id}" do
      VCR.use_cassette("#{model_id}/hello_world") do
        client = Groq::Client.new(model_id: model_id)
        response = client.post(path: "/openai/v1/chat/completions", body: {
          model: model_id,
          messages: [{role: "user", content: "Reply with only the words: Hello, World!"}]
        })
        assert_equal 200, response.status
        response_message = response.body.dig("choices", 0, "message", "content")
        assert_equal "Hello, World!", response_message
      end
    end
  end

  # It's mentioned in the README, so let's assert it too
  def test_default_model
    client = Groq::Client.new
    assert_equal "llama3-8b-8192", client.model_id
  end

  def test_chat_simple_text_message
    VCR.use_cassette("llama3-8b-8192/chat_single_message") do
      client = Groq::Client.new(model_id: "llama3-8b-8192")
      response = client.chat("What's the next day after Wednesday?")
      assert_equal response, {
        "role" => "assistant", "content" => "The next day after Wednesday is Thursday."
      }
    end
  end

  def test_chat_messages
    VCR.use_cassette("llama3-8b-8192/chat_messages") do
      client = Groq::Client.new(model_id: "llama3-8b-8192")
      response = client.chat([
        {role: "user", content: "What's the next day after Wednesday?"},
        {role: "assistant", content: "The next day after Wednesday is Thursday."},
        {role: "user", content: "What's the next day after that?"}
      ])
      assert_equal response, {
        "role" => "assistant", "content" => "The next day after Thursday is Friday."
      }
    end
  end

  include Groq::Helpers
  def test_chat_messages_with_U_A_helpers
    VCR.use_cassette("llama3-8b-8192/chat_messages") do
      client = Groq::Client.new
      # and with U/A helper methods
      response = client.chat([
        S("I am an obedient AI."),
        U("What's the next day after Wednesday?"),
        A("The next day after Wednesday is Thursday."),
        U("What's the next day after that?")
      ], model_id: "llama3-8b-8192")
      assert_equal response, {
        "role" => "assistant", "content" => "The next day after Thursday is Friday."
      }
    end
  end

  def test_json_mode
    VCR.use_cassette("llama3-8b-8192/chat_json_mode") do
      client = Groq::Client.new(model_id: "llama3-8b-8192")
      response = client.chat([
        S("Reply with JSON. Use {\"number\": 7} for the answer."),
        U("What's 3+4?")
      ], json: true)
      assert_equal response, {"role" => "assistant", "content" => "{\"number\": 7}"}
    end
  end

  def test_tools_weather_report
    VCR.use_cassette("mixtral-8x7b-32768/chat_tools_weather_report") do
      client = Groq::Client.new(model_id: "mixtral-8x7b-32768")
      tools = [{
        type: "function",
        function: {
          name: "get_weather_report",
          description: "Get the weather report for a city",
          parameters: {
            type: "object",
            properties: {
              city: {
                type: "string",
                description: "The city or region to get the weather report for"
              }
            },
            required: ["city"]
          }
        }
      }]
      messages = [User("What's the weather in Brisbane, QLD?")]
      response = client.chat(messages, tools: tools)
      # {"role"=>"assistant", "tool_calls"=>[{"id"=>"call_b790", "type"=>"function", "function"=>{"name"=>"get_weather_report", "arguments"=>"{\"city\":\"Brisbane, QLD\"}"}}]}
      assert_equal response["role"], "assistant"
      assert_equal response["tool_calls"].first["type"], "function"
      assert_equal response["tool_calls"].first["function"]["name"], "get_weather_report"
      tool_call_id = response["tool_calls"].first["id"]
      messages << response

      # say with have a get_weather_report(city) function and it returns "25 degrees celcius"
      messages << ToolReply("25 degrees celcius", tool_call_id: tool_call_id, name: "get_weather_report")

      response = client.chat(messages, tools: tools)
      assert_equal response, {"role" => "assistant", "content" => "The weather in Brisbane, QLD is 25 degrees Celsius."}
    end
  end

  def test_max_tokens
    VCR.use_cassette("llama3-8b-8192/chat_max_tokens") do
      client = Groq::Client.new(model_id: "llama3-8b-8192")
      response = client.chat("What's the next day after Wednesday?", max_tokens: 1)
      assert_equal response, {
        "role" => "assistant", "content" => "The"
      }
      # Yeah, max_tokens=1 still returns a full word; because its a single token.
    end
  end
end
