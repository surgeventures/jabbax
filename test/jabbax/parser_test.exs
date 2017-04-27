defmodule Jabbax.ParserTest do
  use ExUnit.Case
  use Plug.Test
  use Jabbax.Document

  def parse(conn, parsers) do
    Plug.Parsers.call(conn, Plug.Parsers.init(parsers: parsers, json_decoder: Poison))
  end

  setup do
    {:ok, json: %{
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
    }}
  end

  test "JSON API document", %{json: json} do
    connection =
      :post
      |> conn("/", Poison.encode!(json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])

    assert connection.body_params == json
  end

  test "plain JSON content type without JSON parser", %{json: json} do
    connection =
      :post
      |> conn("/", Poison.encode!(json))
      |> put_req_header("content-type", "application/json")

    assert_raise(Plug.Parsers.UnsupportedMediaTypeError, fn ->
      parse(connection, [Jabbax.Parser])
    end)
  end

  test "no content type", %{json: json} do
    connection =
      :post
      |> conn("/", Poison.encode!(json))
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
