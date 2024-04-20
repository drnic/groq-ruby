require "active_support/concern"

module Groq::Helpers
  extend ActiveSupport::Concern
  included do
    def U(content)
      {role: "user", content: content}
    end

    def A(content)
      {role: "assistant", content: content}
    end
  end
end
