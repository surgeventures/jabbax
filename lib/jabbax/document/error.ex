defmodule Jabbax.Document.Error do
  defstruct id: nil,
            code: nil,
            status: nil,
            source: nil,
            title: nil,
            detail: nil,
            meta: %{},
            links: %{}
end
