defmodule Jabbax.Document do
  defstruct data: nil,
            errors: [],
            included: [],
            meta: %{},
            links: %{},
            jsonapi: %{version: "1.0"}

  defmacro __using__(_) do
    quote do
      alias Jabbax.Document
      alias Jabbax.Document.{
        ResourceId,
        Resource,
        Link,
        Relationship,
        Error,
        ErrorSource
      }
    end
  end
end
