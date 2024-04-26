require 'rails/generators/base'

module Groq
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_groq_init_file
        create_file "config/initializers/groq.rb", <<~RUBY
          # frozen_string_literal: true

          Groq.configure do |config|
            config.api_key = ENV["GROQ_API_KEY"]
            config.model_id = "llama3-70b-8192"
          end
        RUBY
      end
    end
  end
end
