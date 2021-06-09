defmodule Jabbax.StructureError do
  defexception [:context, :expected, :actual]

  def message(error) do
    """
    Expected #{error.context} to be #{expectation_string(error.expected)}.
    Received: #{inspect(error.actual)}
    """
  end

  defp expectation_string([head | [last]]), do: "#{head} or #{last}"
  defp expectation_string([head | tail]), do: "#{head}, #{expectation_string(tail)}"
  defp expectation_string(expected), do: "#{expected}"
end
