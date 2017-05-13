defmodule Jabbax do
  @moduledoc """
  The main `Jabbax` module provides convenience functions for decoding and
  encoding JSON API messages.

  Jabbax's most important modules are:

  * `Jabbax.Document` - represents a JSON API document that can be validated
  and passed to `Jabbax.Serializer` for JSON string serialization.
  * `Jabbax.Deserializer` - deserializes and validates map representations
  of JSON API messages.
  * `Jabbax.Serializer` - serializes a `Jabbax.Document` structure into its
  map representation to be used with a JSON serializer.
  * `Jabbax.Parser` - a `Plug` parser which handles connections with
  `application/vnd.api+json` content type header and decodes them using
  the JSON decoder of choice.
  * `Jabbax.Plug` - a `Plug` middleware for deserializing requests with
  `application/vnd.api+json` content type into `Jabbax.Document` structures.

  ## Stand-alone usage

  To get started using Jabbax, configure the JSON encoder and decoder you'd
  like to use in your application's configuration file. In our examples we're
  using `Poison` to decode JSON messages.

  ```
  config :jabbax,
    json_encoder: Poison,
    json_decoder: Poison
  ```

  With this simple setup you can start creating, encoding and decoding your
  JSON API documents:

  ```
  use Jabbax.Document

  users_document = %Document{
    data: [
      %Resource{
        id: "5",
        type: "users",
        attributes: %{
          first_name: "John",
          last_name: "Doe",
          email: "john.doe@example.com"
        },
        relationships: %{
          group: %Relationship{
            data: %ResourceId{
              id: "6",
              type: "groups"
            }
          }
        }
      }
    ],
    included: [
      %Resource{
        id: "6",
        type: "groups",
        attributes: %{
          name: "Administrators"
        }
      }
    ],
    meta: %{
      total_count: 150
    }
  }

  json_string = Jabbax.encode!(users_document)
  IO.puts json_string
  # {"meta":{"total-count":150},"jsonapi":{"version":"1.0"} ...

  decoded_document = Jabbax.decode!(json_string)
  IO.inspect decoded_document
  # %Jabbax.Document{data: [%Jabbax.Document.Resource{attributes: ...
  ```
  """
  alias Jabbax.{Serializer, Deserializer}

  def decode!(input) do
    input
    |> Application.get_env(:jabbax, :json_decoder).decode!
    |> Deserializer.call
  end

  def encode!(input) do
    input
    |> Serializer.call
    |> Application.get_env(:jabbax, :json_encoder).encode!
  end

  def encode_to_iodata!(input) do
    input
    |> Serializer.call
    |> Application.get_env(:jabbax, :json_encoder).encode_to_iodata!
  end
end
