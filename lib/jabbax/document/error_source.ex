defmodule Jabbax.Document.ErrorSource do
  @moduledoc false

  defstruct [:pointer, :parameter]

  def from_attribute(attributes) when is_list(attributes) do
    attributes_part =
      attributes
      |> Enum.join("/")

    pointer = "/data/attributes/#{attributes_part}"
    %__MODULE__{pointer: pointer}
  end

  def from_attribute(attribute) do
    from_attribute([attribute])
  end
end
