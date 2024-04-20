# frozen_string_literal: true

require "test_helper"

class TestGroqClient < Minitest::Test
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
end
