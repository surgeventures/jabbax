defmodule Jabbax.Document.Link do
  @moduledoc false

  defstruct href: nil,
            meta: %{}

  @type t :: %__MODULE__{}
end
