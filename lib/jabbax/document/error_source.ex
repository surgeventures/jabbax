defmodule Jabbax.Document.ErrorSource do
  @moduledoc false

  defstruct [:pointer, :parameter]

  def from_attribute(attribute_path) when is_list(attribute_path) do
    pointer = "/data/attributes/" <> Enum.join(attribute_path, "/")
    %__MODULE__{pointer: pointer}
  end

  def from_attribute(attribute) do
    from_attribute([attribute])
  end
end
