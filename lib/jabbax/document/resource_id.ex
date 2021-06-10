defmodule Jabbax.Document.ResourceId do
  @moduledoc false

  defstruct [:id, :type, :meta]

  def from_map(%{id: id, type: type}) do
    %__MODULE__{
      id: id,
      type: type
    }
  end
end
