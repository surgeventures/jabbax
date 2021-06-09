defmodule Jabbax.Document.ErrorSource do
  defstruct [:pointer, :parameter]

  def from_attribute(attribute, prefix \\ []) do
    attribute_prefix =
      prefix
      |> Enum.map(&"#{&1}/")
      |> Enum.join("")

    pointer = "/data/attributes/#{attribute_prefix}#{attribute}"
    %__MODULE__{pointer: pointer}
  end
end
