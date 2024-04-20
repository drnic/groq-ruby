# Groq

Groq Cloud runs LLM models fast and cheap. Llama 3, Mixtrel, Gemma, and more at hundreds of tokens per second, at cents per million tokens.

[![speed-pricing](docs/images/groq-speed-price-20240421.png)](https://wow.groq.com/)

Speed and pricing at 2024-04-21.

## Groq Cloud API

You can interact with their API using any Ruby HTTP library by following their documentation at <https://console.groq.com/docs/quickstart>

The Groq Cloud API looks to be copying a subset of the OpenAI API. For example, you perform chat completions at `https://api.groq.com/openai/v1/chat/completions` with the same POST body schema as OpenAI. The Tools support looks to have the same schema for defining tools/functions.

So you can write your own Ruby client code to interact with the Groq Cloud API.

Or you can use this convenience RubyGem with some nice helpers to get you started.

```ruby
client = Groq::Client.new
client.chat("Hello, world!")
=> {"role"=>"assistant", "content"=>"Hello there! It's great to meet you!"}

include Groq::Helpers
client.chat([
    U("Hi"),
    A("Hello back. Ask me anything. I'll reply with 'cat'"),
    U("Favourite food?")
])
# => {"role"=>"assistant", "content"=>"Um... CAT"}
# => {"role"=>"assistant", "content"=>"Not a cat! It's a pizza!"}
# => {"role"=>"assistant", "content"=>"Pizza"}
# => {"role"=>"assistant", "content"=>"Cat"}
```

## Installation

Install the gem and add to the application's Gemfile by executing:

```plain
bundle add groq
```

If bundler is not being used to manage dependencies, install the gem by executing:

```plain
gem install groq
```

## Usage

- Get your API key from [console.groq.com/keys](https://console.groq.com/keys)
- Place in env var `GROQ_API_KEY`, or explicitly pass into configuration below.
- Use the `Groq::Client` to interact with Groq and your favourite model.

```ruby
client = Groq::Client.new # uses ENV["GROQ_API_KEY"] and "llama3-8b-8192"
client = Groq::Client.new(api_key: "...", model_id: "llama3-8b-8192")

Groq.configuration do |config|
  config.api_key = "..."
  config.model_id = "llama3-70b-8192"
end
client = Groq::Client.new
```

There is a simple chat function to send messages to a model:

```ruby
# either pass a single message and get a single response
client.chat("Hello, world!")
=> {"role"=>"assistant", "content"=>"Hello there! It's great to meet you!"}

# or pass in a messages array containing multiple messages between user and assistant
client.chat([
    {role: "user", content: "What's the next day after Wednesday?"},
    {role: "assistant", content: "The next day after Wednesday is Thursday."},
    {role: "user", content: "What's the next day after that?"}
])
# => {"role" => "assistant", "content" => "The next day after Thursday is Friday."}
```

### Message helpers

We also have some handy `U`, `A`, and `F` methods to produce the `{role:, content:}` hashes:

```ruby
include Groq::Helpers
client.chat([
    U("Hi"),
    A("Hello back. Ask me anything. I'll reply with 'cat'"),
    U("Favourite food?")
])
# => {"role"=>"assistant", "content"=>"Um... CAT"}
# => {"role"=>"assistant", "content"=>"Not a cat! It's a pizza!"}
# => {"role"=>"assistant", "content"=>"Pizza"}
# => {"role"=>"assistant", "content"=>"Cat"}
```

The `T()` is to provide function/tool responses:

```
T("tool", tool_call_id: "call_b790", name: "get_weather_report", content: "25 degrees celcius")
# => {"role"=>"function", "tool_call_id"=>"call_b790", "name"=>"get_weather_report", "content"=>"25 degrees celcius"}
```

There are also aliases for each helper function:

* `U(content)` is also `User(content)`
* `A(content)` is also `Assistant(content)`
* `T(content, ...)` is also `Tool`, `ToolReply`, `Function`, `F`

### Specifying an LLM model

At the time of writing, Groq Cloud service supports a limited number of models. They've suggested they'll allow uploading custom models in future.

To get the list of known model IDs:

```ruby
Groq::Model.model_ids
=> ["llama3-8b-8192", "llama3-70b-8192", "llama2-70b-4096", "mixtral-8x7b-32768", "gemma-7b-it"]
```

To get more data about each model, see `Groq::Model::MODELS`.

As above, you can specify the default model to use for all `chat()` calls:

```ruby
client = Groq::Client.new(model_id: "llama3-70b-8192")
# or
Groq.configuration do |config|
  config.model_id = "llama3-70b-8192"
end
```

You can also specify the model within the `chat()` call:

```ruby
client.chat("Hello, world!", model_id: "llama3-70b-8192")
```

To see all known models reply:

```ruby
puts "User message: Hello, world!"
Groq::Model.model_ids.each do |model_id|
  puts "Assistant reply with model #{model_id}:"
  p client.chat("Hello, world!", model_id: model_id)
end
```

The output might looks similar to:

```plain
User message: Hello, world!
Assistant reply with model llama3-8b-8192:
{"role"=>"assistant", "content"=>"Hello, world! It's great to meet you! Is there something I can help you with, or would you like to chat?"}
Assistant reply with model llama3-70b-8192:
{"role"=>"assistant", "content"=>"The classic \"Hello, world!\" It's great to see you here! Is there something I can help you with, or would you like to just chat?"}
Assistant reply with model llama2-70b-4096:
{"role"=>"assistant", "content"=>"Hello, world!"}
Assistant reply with model mixtral-8x7b-32768:
{"role"=>"assistant", "content"=>"Hello! It's nice to meet you. Is there something specific you would like to know or talk about? I'm here to help answer any questions you have to the best of my ability. I can provide information on a wide variety of topics, so feel free to ask me anything. I'm here to assist you."}
Assistant reply with model gemma-7b-it:
{"role"=>"assistant", "content"=>"Hello to you too! 👋🌎 It's great to hear from you. What would you like to talk about today? 😊"}
```

### Tools/Functions

LLMs are increasingly supporting deferring to tools or functions to fetch data, perform calculations, or store structured data. Groq Cloud in turn then supports their tool implementations through its API.

See the [Using Tools](https://console.groq.com/docs/tool-use) documentation for the list of models that currently support tools.

```ruby
client = Groq::Client.new(model_id: "mixtral-8x7b")
```

The Groq/OpenAI schema for defining a tool/function (which differs from the Anthropic/Claude3 schema) is:

```ruby
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
```

Pass the `tools` array into the `chat()` call:

```ruby
include Groq::Helpers
messages = [U("What's the weather in Paris?")]
response = client.chat(messages, tools: tools)
# => {"role"=>"assistant", "tool_calls"=>[{"id"=>"call_b790", "type"=>"function", "function"=>{"name"=>"get_weather_report", "arguments"=>"{\"city\":\"Paris\"}"}}]}
```

You'd then invoke the Ruby implementation of `get_weather_report` to return the weather report for Paris as the next message in the chat.

```ruby
messages << response

tool_call_id = response["tool_calls"].first["id"]
messages << T("25 degrees celcius", tool_call_id: tool_call_id, name: "get_weather_report")
client.chat(messages)
# => {"role"=>"assistant", "content"=> "I'm glad you called the function!\n\nAs of your current location, the weather in Paris is indeed 25°C (77°F)..."}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drnic/groq-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/drnic/groq-ruby/blob/develop/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Groq project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/drnic/groq-ruby/blob/develop/CODE_OF_CONDUCT.md).
