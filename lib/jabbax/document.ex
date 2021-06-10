defmodule Jabbax.Document do
  @moduledoc false

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
        Error,
        ErrorSource,
        Link,
        Relationship,
        Resource,
        ResourceId
      }
    end
  end
end
