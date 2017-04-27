defmodule Jabbax.ParserTest do
  use ExUnit.Case
  use Plug.Test
  use Jabbax.Document

  @sample_json %{
    "data" => %{
      "id" => "1",
      "type" => "user",
      "attributes" => %{
        "name" => "Sample User"
      }
    },
    "jsonapi" => %{
      "version" => "1.0"
    }
  }

  def parse(conn, parsers) do
    Plug.Parsers.call(conn, Plug.Parsers.init(parsers: parsers, json_decoder: Poison))
  end

  test "JSON API document" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])

    assert connection.body_params == @sample_json
  end

  test "plain JSON content type without JSON parser" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> put_req_header("content-type", "application/json")

    assert_raise(Plug.Parsers.UnsupportedMediaTypeError, fn ->
      parse(connection, [Jabbax.Parser])
    end)
  end

  test "no content type" do
    connection =
      :post
      |> conn("/", Poison.encode!(@sample_json))
      |> parse([Jabbax.Parser])

    assert connection.body_params == %{}
  end

  test "empty request body" do
    connection =
      :post
      |> conn("/", "")
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])

    assert connection.body_params == %{}
  end
end
