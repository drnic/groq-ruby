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

> 🍕 Hello! Thank you for calling our pizzeria. I'm happy to help you with your inquiry. Do you have a question about our menu or would you like to place an order?
>
> 😋 What's your cheapest?
>
> 🍕 Our cheapest menu item is the Garlic Knots (6 pieces), which is served with marinara sauce and priced at $5. Would you like to add it to your order or is there something else that catches your attention?
>
> 😋 Yes. And a cheap pizza.
>
> 🍕 Our cheapest pizza option is the Veggie Pizza. It comes with tomato sauce, mozzarella, and a mix of bell peppers, onions, and mushrooms, all for $13. Would you like to order the Veggie Pizza and the Garlic Knots together?
>
> 😋 Yep
>
> 🍕 I've taken note of your order. You're ordering a Veggie Pizza and 6 Garlic Knots. Your total comes out to be $18. Would you like to pay by credit card, cash, or take any other payment method?
>
> 😋 summary
>
> Here is a summary of the current conversation:
>
> The conversation started with a customer calling the pizzeria and speaking with an AI assistant. The assistant offered to help with menu inquiries or taking an order. The customer was considering ordering from the menu. The assistant presented the cheapest menu item, Garlic Knots, and asked if the customer wanted to add it to their order. The customer may have been interested in other options as well. The assistant then presented the cheapest pizza option, the Veggie Pizza, and asked if the customer wanted to order it along with the Garlic Knots. The customer agreed, and the assistant took note of the order, which consisted of a Veggie Pizza and 6 Garlic Knots for a total of $18. The assistant asked how the customer would like to pay for their order.
>
> 😋 exit

## Two Agents

Here is an example of two agents talking to each other, without any user input.

### Buying Pizza

```bash
bundle exec examples/groq-two-agents-chatting.rb --agent-prompt examples/agent-prompts/pizzeria-sales.yml --agent-prompt examples/agent-prompts/food-customer.yml
```

This will proceed for 10 turns, with the agents taking turns to speak. Pass the `-i 15` option to increase the number of turns.

> 🍕 Hello! Welcome to Pizza Palace. Thank you for reaching out to us. How can I assist you today?
>
> 😋 Hi! Thanks for having me. I'm actually pretty hungry, so I'm looking to order some food. Can you tell me a bit about your menu? What are some of your popular items?
>
> 🍕 I'd be happy to tell you more about our menu. We have a variety of delicious options to choose from. Our most popular items include our Margherita Pizza, Pepperoni Pizza, and BBQ Chicken Pizza. The Margherita is a classic with tomato sauce, mozzarella, and fresh basil. The Pepperoni Pizza is a crowd-pleaser with a generous layer of pepperoni on top. And our BBQ Chicken Pizza has a sweet and tangy BBQ sauce, topped with chicken, onions, and cilantro.
>
> We also have some great non-pizza options, such as our Garlic Knots, which are a favorite among our customers. And for dessert, our Cannoli are a must-try - they're filled with creamy ricotta cheese and chocolate chips.
>
> What sounds good to you? Would you like me to walk you through our entire menu or is there something specific you're in the mood for?
>
> 😋 Mmm, everything sounds delicious! I think I'll go for something a bit hearty. Can you tell me more about the BBQ Chicken Pizza? What kind of chicken is used? And is the pepperoni on the Pepperoni Pizza thick-cut or thin-cut?
>
> Also, how would you recommend ordering the Garlic Knots? Are they a side dish or can I get them as part of a combo?
