defmodule JabbaxTest do
  use ExUnit.Case
  use Jabbax.Document
  alias Jabbax

  test "decode!" do
    assert Jabbax.decode!("{\"jsonapi\":{\"version\":\"1.0\"},\"data\":null}") ==
             %Document{jsonapi: %{version: "1.0"}}
  end

  test "encode!" do
    assert Jabbax.encode!(%Document{}) ==
             "{\"jsonapi\":{\"version\":\"1.0\"},\"data\":null}"
  end
end
