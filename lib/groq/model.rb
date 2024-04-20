class Groq::Model
  MODELS = [
    {
      name: "LLaMA3 8b",
      model_id: "llama3-8b-8192",
      developer: "Meta",
      context_window: 8192,
      model_card: "https://huggingface.co/meta-llama/Meta-Llama-3-8B"
    },
    {
      name: "LLaMA3 70b",
      model_id: "llama3-70b-8192",
      developer: "Meta",
      context_window: 8192,
      model_card: "https://huggingface.co/meta-llama/Meta-Llama-3-70B"
    },
    {
      name: "LLaMA2 70b",
      model_id: "llama2-70b-4096",
      developer: "Meta",
      context_window: 4096,
      model_card: "https://huggingface.co/meta-llama/Llama-2-70b"
    },
    {
      name: "Mixtral 8x7b",
      model_id: "mixtral-8x7b-32768",
      developer: "Mistral",
      context_window: 32768,
      model_card: "https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1"
    },
    {
      name: "Gemma 7b",
      model_id: "gemma-7b-it",
      developer: "Google",
      context_window: 8192,
      model_card: "https://huggingface.co/google/gemma-1.1-7b-it"
    }
  ]

  class << self
    def model_ids
      MODELS.map { |m| m[:model_id] }
    end

    def default_model
      MODELS.first
    end

    def default_model_id
      default_model[:model_id]
    end
  end
end
