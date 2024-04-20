# frozen_string_literal: true

require "test_helper"

class TestGroqClient < Minitest::Test
  # define "say hello world" for each model, such as: test_hello_world_llama3_8b et al
  Groq::Model::MODELS.each do |model|
    define_method :"test_hello_world_#{model[:model_id]}" do
      VCR.use_cassette("#{model[:model_id]}/hello_world") do
        client = Groq::Client.new
        response = client.post(path: "/openai/v1/chat/completions", body: {
          model: model[:model_id],
          messages: [{role: "user", content: "Reply with only the words: Hello, World!"}]
        })
        assert_equal 200, response.status
        response_message = response.body.dig("choices", 0, "message", "content")
        assert_equal "Hello, World!", response_message
      end
    end
  end
end
