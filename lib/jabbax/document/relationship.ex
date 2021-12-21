defmodule Jabbax.Document.Relationship do
  @moduledoc false

  defstruct data: nil,
            links: %{},
            meta: %{}

  @type t :: %__MODULE__{}
end
