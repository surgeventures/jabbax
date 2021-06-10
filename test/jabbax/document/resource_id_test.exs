defmodule Jabbax.Document.ResourceIdTest do
  use ExUnit.Case
  alias Jabbax.Document.ResourceId

  test "#from_map" do
    assert ResourceId.from_map(%{
      id: 1,
      type: "user"
    }) == %ResourceId{
      id: 1,
      type: "user"
    }
  end
end
