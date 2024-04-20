# frozen_string_literal: true

require_relative "groq/version"

module Groq
  autoload :Configuration, "groq/configuration"
  autoload :Client, "groq/client"
  autoload :Model, "groq/model"

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
