defmodule Jabbax.Document.ErrorSource do
  @moduledoc false

  defstruct [:pointer, :parameter]

  def from_attribute(attribute) do
    %__MODULE__{pointer: "/data/attributes/#{attribute}"}
  end
end
