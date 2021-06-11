defmodule Jabbax.Document.Error do
  @moduledoc false

  defstruct id: nil,
            code: nil,
            status: nil,
            source: nil,
            title: nil,
            detail: nil,
            meta: %{},
            links: %{}
end
