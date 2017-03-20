# Jabbax

There's one great thing about [the way Han Solo was "packaged" for transportation to Jabba the
Hutt][Han Solo serialization]. You see, once you freeze someone in carbonite, you make it very
clear and explicit as to your intentions towards the poor guy. Everyone can see it without thinking
twice and nobody will even dare to ask silly questions about the package format or its recipient.

This transparency and explicitness, although without the unnecessary glimpse of terror, was the
reason for creating yet another JSON API wrapper package, one that would fit the Elixir/Phoenix
ecosystems which on their own also promote explicitness and simplicity over DSLs and magic.

So here is the **JSON API Building Blocks Assembly for Elixir**. Use it, as Jabba once did, to set
a brutally clear example as to how explicit and readable your JSON API view code should be.

## Philosophy

As opposed to the DSL-powered serializer approach, Jabbax tries to stay away from your view
layer logic. It simply provides you with all the building blocks that you'll need to assemble a
complete JSON API document, structured to resemble the actual JSON API document structure. This has
the following advantages:

- your view code works on ("talks in the language of") the real JSON API structure, just as HTML,
  JSON or any other views are meant express structures of the relevant standard with Elixir code
- you have the flexibility to abstract away common or repetitive parts into any code structures
  that you choose as a best fit for your business domain and project specifics
- your view code is explicit and easy to reason about, because each document is either explicitly
  assembled in the view or explicitly abstracted away into separate functions or modules
- you'll never hit the wall of an edge case scenario unsupported by serialization DSL, such as a
  need to include deeply nested structures that are not following the standard Ecto structure etc

Once you assemble the document, Jabbax takes it from there and serializes (or deserializes) the
`Jabbax.Document` structure to (or from) a JSON string. At this phase, Jabbax does provide [a few
basic conveniences](#conveniences) to make sure your output strictly follows the JSON API
requirements and recommendations without you having to care for some minor details. But other than
than, everything is under your control.

Yes, initially it's more code to be written than with out-of-the-box DSL-based serializers and it
does require an initial understanding of the [JSON API specs][JSON API spec], but that may actually
be a good thing which you may come to appreciate once your project grows with more and more
business cases.

## Installation

Add `jabbax` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:jabbax, git: "https://github.com/surgeventures/jabbax.git"}]
end
```

## Usage

### Assemble

Basically, you want to use the structs available in the `Jabbax.Document` namespace to assemble a
[proper JSON API document][JSON API spec]. Usually, you'll do it somewhere in the view layer of
your application. Here's an example:

```elixir
%Document{
  data: [
    %Resource{
      type: "users",
      id: 1,
      attributes: %{
        name: "Some guy",
        days_active: 123
      }
    },
    %Resource{
      type: "users",
      id: 2,
      attributes: %{
        name: "Other guy",
        days_active: 234
      }
    }
  ]
}
```

For the time being the complete documentation of each building block isn't ready yet, but you can
see complete usage examples in tests for [Jabbax.Serializer](./test/jabbax/serializer_test.exs) and
[Jabbax.Deserializer](./test/jabbax/deserializer_test.exs).

#### Conveniences

You do get some extras out of the box from Jabbax in order to stay intact with JSON API
requirements and recommendations without you having to care for some minor details. These include:

- dasherization of members that are recommended to be dasherized, ie. attribute keys, meta keys,
  relationship names, link names, resource types, error codes and source pointers
- exclusion of empty structures that wouldn't make sense as nulls, ie. attribute maps, meta maps
  relationship maps, link maps, error lists, included lists
- casting of atom keys and integer ids to strings
- inclusion of JSON API version structure

### Encode

Once you have a `Jabbax.Document` structure ready to go out, you can pass it to `Jabbax.encode!`
to generate a JSON API compilant JSON string, cold as a rock. That's it for the manual approach.

In case of Phoenix projects, you can have this done automatically by registering a JSON API media
type in Plug and setting Jabbax as its Phoenix format handler:

```elixir
config :plug, :types,
  %{"application/vnd.api+json" => ["json-api"]}

config :phoenix, :format_encoders,
  "json-api": Jabbax
```

Finally, you can enforce your pipeline to only work with this specific media type:

```elixir
pipeline :api do
  plug :accepts, ["json-api"]
end
```

Now, you can simply return `Jabbax.Document` structs from your views, like this:

```elixir
defmodule MyProject.Web.UserView do
  use MyProject.Web, :view
  use Jabbax.Document

  def render("show.json-api", %{user: user}) do
    %Document{
      data: %Resource{
        type: "users",
        id: user.id,
        attributes: %{
          name: user.name,
          days_active: user.days_active
        }
      }
    }
  end
end
```

### Decode

If your project consumes JSON API documents besides generating them, you can pass the document body
string to `Jabbax.decode!` to get the `Jabbax.Document` structure, decontaminated & ready to roll.

Once again, you can simplify this if you're using Plug. In that case, you can plug
`Jabbax.Deserializer` into your pipeline like this:

```elixir
pipeline :api do
  plug :accepts, ["json-api"]
  plug Jabbax.Deserializer
end
```

If the request has a proper content type (`application/vnd.api+json`), this plug will patch the
`conn.body_params` filled by `Plug.Parsers` to include the `Jabbax.Document` structure instead of
plain JSON. You can then access it in your Phoenix controller like below:

```elixir
defmodule MyProject.Web.UserController do
  use MyProject.Web, :controller
  alias MyProject.Accounts

  def create(conn = %{body_params: doc}, _) do
    with {:ok, %User{} = user} <- Accounts.create_user(doc.data.attributes) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render(user: user)
    end
  end
end
```

### Configure

Here's an example Jabbax config that you could add to your `config.exs`, along with the defaults:

```elixir
config :jabbax,
  json_encoder: Poison,
  json_decoder: Poison
```

## License

Jabbax source code is released under MIT License. Check LICENSE file for more information.

[Han Solo serialization]: https://www.youtube.com/watch?v=qND0aIXOLbw
[JSON API spec]: http://jsonapi.org/format
