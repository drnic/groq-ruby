# frozen_string_literal: true

require "test_helper"

class TestGroqModel < Minitest::Test
  def test_load_models
    VCR.use_cassette("api/get_models") do
      client = Groq::Client.new
      models = Groq::Model.load_models(client: client)
      expected = {
        "object" => "list",
        "data" => [
          {"id" => "gemma-7b-it", "object" => "model", "created" => 1693721698, "owned_by" => "Google", "active" => true, "context_window" => 8192},
          {"id" => "llama2-70b-4096", "object" => "model", "created" => 1693721698, "owned_by" => "Meta", "active" => true, "context_window" => 4096},
          {"id" => "llama3-70b-8192", "object" => "model", "created" => 1693721698, "owned_by" => "Meta", "active" => true, "context_window" => 8192},
          {"id" => "llama3-8b-8192", "object" => "model", "created" => 1693721698, "owned_by" => "Meta", "active" => true, "context_window" => 8192},
          {"id" => "mixtral-8x7b-32768", "object" => "model", "created" => 1693721698, "owned_by" => "Mistral AI", "active" => true, "context_window" => 32768}
        ]
      }
      assert_equal expected, models
    end
  end
end
