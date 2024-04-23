# Examples

## User Chat

Chat with a pre-defined agent using the following command:

```bash
bundle exec examples/groq-user-chat.rb
# or
bundle exec examples/groq-user-chat.rb --agent-prompt examples/agent-prompts/helloworld.yml
```

There are two example agent prompts available:

- `examples/agent-prompts/helloworld.yml` (the default)
- `examples/agent-prompts/pizzeria-sales.yml`

At the prompt, either talk to the AI agent, or some special commands:

- `exit` to exit the conversation
- `summary` to get a summary of the conversation so far

### Pizzeria

Run the pizzeria example with the following command:

```bash
bundle exec examples/groq-user-chat.rb --agent-prompt examples/agent-prompts/pizzeria-sales.yml
```

> 🍕 Hello! Welcome to our pizza store! Can I take your order today? We have our delicious Hawaiian pizzas and pepperoni pizzas available in small and large sizes, priced at $10 and $20 respectively. Would you like to place an order?
>
> 😋 Hawaiian please
>
> 🍕 Our Hawaiian pizza is a fan favorite! Would you like that in small or large size? Keep in mind that small is $10 and large is $20.
>
> 😋 Small
>
> 🍕 One small Hawaiian pizza coming right up! I'll get that ready for you. Pick it up when you come by, ready in just 10 minutes. Cash only when you pick it up. See you soon!
>
> 😋 Actually make it large. Two.
>
> 🍕 No problem! Two large Hawaiian pizzas, coming right up! That'll be $40, please. Pick them up in about 10 minutes, cash only when you get here. See you soon!
>
> 😋 Sorry, my wife said she wants pepperoni
>
> 🍕 Trade-in no problem! I'll swap out one of the Hawaiian pizzas for a large pepperoni pizza. So, you want one large Hawaiian pizza and one large pepperoni pizza, correct? Pick them up in 10 minutes, cash only when you get here. See you soon!
>
> 😋 summary
>
> Here is a summary of the current conversation:
>
> The conversation started with the assistant welcoming a customer to the pizza store and offering a menu consisting of Hawaiian and pepperoni pizzas in small and large sizes. The customer initially ordered a single small Hawaiian pizza, which would be ready in 10 minutes for pick-up and paid with cash.
>
> The customer then added a second order, requesting two large Hawaiian pizzas for a total cost of $40. However, they later asked to trade-in one of the Hawaiian pizzas for a large pepperoni pizza, resulting in an order of one large Hawaiian pizza and one large pepperoni pizza. The pizzas will be ready for pick-up in 10 minutes, paid with cash.
>
> 😋 exit
