defmodule Jabbax.Document.ErrorSourceTest do
  use ExUnit.Case
  alias Jabbax.Document.ErrorSource

  test "#from_attribute" do
    assert ErrorSource.from_attribute(:first_name) ==
      %ErrorSource{pointer: "/data/attributes/first_name"}
  end
end

