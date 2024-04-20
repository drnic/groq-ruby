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
client = Groq::Client.new # uses ENV["GROQ_API_KEY"]
client = Groq::Client.new(api_key: "...")

Groq.configuration do |config|
  config.api_key = "..."
end
client = Groq::Client.new
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
