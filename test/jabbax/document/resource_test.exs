defmodule Jabbax.Document.ResourceTest do
  use ExUnit.Case
  alias Jabbax.Document.Resource

  test "#from_map" do
    assert Resource.from_map(%{
      id: 1,
      type: "user",
      age: 21
    }) == %Resource{
      id: 1,
      type: "user",
      attributes: %{
        age: 21
      }
    }
  end
end
