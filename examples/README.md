# Examples

## User Chat

Chat with a pre-defined agent using the following command:

```bash
bundle exec examples/user-chat.rb
# or
bundle exec examples/user-chat.rb --agent-prompt examples/agent-prompts/helloworld.yml
```

There are two example agent prompts available:

- `examples/agent-prompts/helloworld.yml` (the default)
- `examples/agent-prompts/pizzeria-sales.yml`

At the prompt, either talk to the AI agent, or some special commands:

- `exit` to exit the conversation
- `summary` to get a summary of the conversation so far

### Streaming text chunks

There is also an example of streaming the conversation to terminal as it is received from Groq API.

It defaults to the slower `llama3-70b-8192` model so that the streaming is more noticable.

```bash
bundle exec examples/user-chat-streaming.rb --agent-prompt examples/agent-prompts/pizzeria-sales.yml
```

### Streaming useful chunks (e.g. JSON)

If the response is returning a list of objects, such as a sequence of JSON objects, you can try to stream the chunks that make up the JSON objects and process them as soon as they are complete.

```bash
bundle exec examples/streaming-to-json-objects.rb
```

This will produce JSON for each planet in the solar system, one at a time. The API does not return each JSON as a chunk, rather it only returns `{` and `"` and `name` as distinct chunks. But the example code [`examples/streaming-to-json-objects.rb`](examples/streaming-to-json-objects.rb) shows how you might build up JSON objects from chunks, and process it (e.g. store to DB) as soon as it is complete.

The system prompt used is:

```plain
Write out the names of the planets of our solar system, and a brief description of each one.

Return JSON object for each one:

{ "name": "Mercury", "position": 1, "description": "Mercury is ..." }

Between each response, say "NEXT" to clearly delineate each JSON response.
```

The code in the repo uses the `NEXT` token to know when to process the JSON object.

The output will look like, with each Ruby Hash object been pretty printed when it has been built from chunks.

```json
{"name"=>"Mercury",
 "position"=>1,
 "description"=>"Mercury is the smallest planet in our solar system, with a highly elliptical orbit that takes it extremely close to the sun."}
{"name"=>"Venus",
 "position"=>2,
 "description"=>
  "Venus is often called Earth's twin due to their similar size and mass, but it has a thick atmosphere that traps heat, making it the hottest planet."}
```

### Pizzeria

Run the pizzeria example with the following command:

```bash
bundle exec examples/user-chat.rb --agent-prompt examples/agent-prompts/pizzeria-sales.yml
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
