defmodule Jabbax.Document.Resource do
  @moduledoc false

  defstruct id: nil,
            type: nil,
            attributes: %{},
            relationships: %{},
            links: %{},
            meta: %{}

  def from_map(map = %{id: id, type: type}) do
    %__MODULE__{
      id: id,
      type: type,
      attributes: map |> Map.drop([:id, :type])
    }
  end
end
