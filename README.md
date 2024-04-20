# Groq


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

We also have some handy `U` and `A` methods to produce the `{role:, content:}` hash:

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drnic/groq-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/drnic/groq-ruby/blob/develop/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Groq project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/drnic/groq-ruby/blob/develop/CODE_OF_CONDUCT.md).
