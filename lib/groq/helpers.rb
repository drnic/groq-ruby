require "active_support/concern"

module Groq::Helpers
  extend ActiveSupport::Concern
  included do
    def U(content)
      {role: "user", content: content}
    end
    alias_method :User, :U

    def A(content)
      {role: "assistant", content: content}
    end
    alias_method :Assistant, :A

    def S(content)
      {role: "system", content: content}
    end
    alias_method :System, :S

    def T(content, tool_call_id:, name:)
      {role: "function", tool_call_id: tool_call_id, name: name, content: content}
    end
    alias_method :Tool, :T
    alias_method :ToolReply, :T
    alias_method :Function, :T
    alias_method :F, :T
  end
end
