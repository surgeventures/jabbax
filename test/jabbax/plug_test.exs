defmodule Jabbax.PlugTest do
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
      |> Jabbax.Plug.call(Jabbax.Plug.init(nil))

    assert connection.assigns[:doc] == %Document{
      data: %Resource{
        id: "1",
        type: "user",
        attributes: %{
          "name" => "Sample User"
        }
      },
      jsonapi: %{version: "1.0"}
    }
  end

  test "JSON API document with custom assign name", %{json: json} do
    connection =
      :post
      |> conn("/", Poison.encode!(json))
      |> put_req_header("content-type", "application/vnd.api+json")
      |> parse([Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(assign: :custom_doc))

    assert connection.assigns[:custom_doc] == %Document{
      data: %Resource{
        id: "1",
        type: "user",
        attributes: %{
          "name" => "Sample User"
        }
      },
      jsonapi: %{version: "1.0"}
    }
  end

  test "other content type", %{json: json} do
    connection =
      :post
      |> conn("/", Poison.encode!(json))
      |> put_req_header("content-type", "application/json")
      |> parse([:json, Jabbax.Parser])
      |> Jabbax.Plug.call(Jabbax.Plug.init(nil))

    assert connection.assigns[:custom_doc] == nil
  end
end
