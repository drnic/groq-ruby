# frozen_string_literal: true

require_relative "groq/version"

module Groq
  autoload :Configuration, "groq/configuration"
  autoload :Client, "groq/client"
  autoload :Model, "groq/model"
  autoload :Helpers, "groq/helpers"

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
